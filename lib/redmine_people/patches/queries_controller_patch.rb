# This file is a part of Redmine People (redmine_people) plugin,
# humanr resources management plugin for Redmine
#
# Copyright (C) 2011-2025 RedmineUP
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

module RedminePeople
  module Patches
    module QueriesControllerPatch
      def self.included(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        def redirect_to_dayoff_query(options)
          redirect_to dayoff_query_path(options)
        end

        def dayoff_query_path(options)
          @project ? project_dayoffs_path(options.merge(project_id: @project.id)) : dayoffs_path(options)
        end
      end
    end
  end
end

unless QueriesController.included_modules.include?(RedminePeople::Patches::QueriesControllerPatch)
  QueriesController.send(:include, RedminePeople::Patches::QueriesControllerPatch)
end
