# This file is a part of Redmine People (redmine_people) plugin,
# humanr resources management plugin for Redmine
#
# Copyright (C) 2011-2026 RedmineUP
# http://www.redmineup.com/
#
# redmine_people is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_people is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_people.  If not, see <http://www.gnu.org/licenses/>.

require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'

module RedminePeople
  module Patches
    module UserPatch
      def self.prepended(base)
        base.class_eval do
          has_one :avatar, lambda { where("#{Attachment.table_name}.description = 'avatar'") }, :class_name => 'Attachment', :as => :container, :dependent => :destroy
          acts_as_attachable_global

          def self.clear_safe_attributes
            @safe_attributes.collect! do |attrs, options|
              if attrs.collect!(&:to_s).include?('firstname')
                [attrs - ['firstname', 'lastname', 'mail', 'custom_field_values', 'custom_fields'], options]
              else
                [attrs, options]
              end
            end
          end
          self.clear_safe_attributes

          safe_attributes 'firstname', 'lastname', 'mail', 'custom_field_values', 'custom_fields',
          :if => lambda { |user, current_user| current_user.allowed_people_to?(:edit_people, user) || (user.new_record? && current_user.anonymous? && Setting.self_registration?) }
        end
      end

      def project
        @project ||= Project.new
      end

      def allowed_people_to?(permission, person = nil)
        unless RedminePeople.available_permissions.include?(permission)
          raise "The permission #{permission} does not exist"
        end

        return true if admin?

        if respond_to?(:"check_permission_#{permission.to_s}", true)
          send("check_permission_#{permission}".to_sym, person)
        else
          has_permission?(permission)
        end
      end

      def allowed_to?(action, context, options={}, &block)
        return allowed_people_to?(action) if !action.is_a?(Hash) && RedminePeople.available_permissions.include?(action)

        super(action, context, options, &block)
      end

      def has_permission?(permission)
        (groups + [self]).any? { |principal| PeopleAcl.allowed_to?(principal, permission) }
      end

      protected

      def check_permission_view_people(person)
        return true if person && person.is_a?(User) && person.id == id
        return true if !anonymous? && Setting.plugin_redmine_people['visibility'].to_i > 0

        has_permission?(:view_people)
      end

      def check_permission_edit_people(person)
        return has_permission?(:edit_people) unless person.is_a?(User)

        self_person = becomes(Person)
        can_edit_person?(self_person, person)
      end

      def check_permission_view_performance(person)
        (person.is_a?(User) && person.id == self.id) || has_permission?(:view_performance)
      end

      private

      def can_edit_person?(self_person, person)
        return true if can_edit_own_data?(person)

        if has_permission?(:edit_subordinates)
          return true if can_edit_subordinates?(self_person, person)
        end

        has_permission?(:edit_people)
      end

      def can_edit_own_data?(person)
        person.id == id && Setting.plugin_redmine_people['edit_own_data'].to_i > 0
      end

      def can_edit_subordinates?(self_person, person)
        if person.respond_to?(:manager_id)
          current_ids = [self.id]

          while current_ids.any?
            return true if current_ids.include?(person.id)

            current_ids = PeopleInformation.where(manager_id: current_ids).pluck(:user_id)
          end
        end
        if self_person.department && person.department
          subordinate_ids = self_person.department.people_of_branch_department.ids

          return true if person.department.is_head?(self_person)
          return true if subordinate_ids.include?(person.id) && self_person.department != person.department
        end

        false
      end
    end
  end
end

User.prepend(RedminePeople::Patches::UserPatch)
