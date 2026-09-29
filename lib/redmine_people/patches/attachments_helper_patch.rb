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
    module AttachmentsHelperPatch
      def container_attachments_download_path(container)
        return departments_attachments_download_path container.class.name.underscore.pluralize, container.id if container.is_a?(Department)

        super(container)
      end
    end
  end
end

if Redmine::VERSION.to_s >= '5.0'
  AttachmentsHelper.prepend(RedminePeople::Patches::AttachmentsHelperPatch)
end
