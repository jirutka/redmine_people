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

require_dependency 'application_helper'

module RedminePeople
  module Patches
    module ApplicationHelperPatch
      def self.prepended(base)
        base.class_eval do
          unless RedminePeople.module_exists?(:AvatarsHelper)
            include AvatarsHelperPatch
          end
        end
      end

      def link_to_user(user, options = {})
        if user.is_a?(User)
          name = h(user.name(options[:format]))
          if user.active? && User.current.allowed_people_to?(:view_people, user)
            link_to name, person_url(user, options.except(:format))
          else
            link_to_principal(user, options)
          end
        else
          h(user.to_s)
        end
      end

      def format_object(object, html = true, &block)
        case object.class.name
        when 'Department'
          html ? format_department(object) : object.to_s
        when 'Person'
          html ? link_to_user(object, { only_path: true }) : object.to_s
        else
          return object.to_s if %w[CustomValue CustomFieldValue].include?(object.class.name) && object.customized.is_a?(Person)

          super(object, html, &block)
        end
      end
    end
  end
end

ApplicationHelper.prepend(RedminePeople::Patches::ApplicationHelperPatch)
