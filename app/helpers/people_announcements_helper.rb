# encoding: utf-8
#
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

module PeopleAnnouncementsHelper
  def announcement_status
    params[:announcements_status] || 'active'
  end

  def recipients_options_for_select
    selected = @note.recipient ? "#{@note.recipient_type}:#{@note.recipient_id}" : nil

    dept_options = department_tree_options_for_select(Department.all.sort) do |d|
      value = "Department:#{d.id}"
      { value: value, selected: (value == selected ? 'selected' : nil) }
    end

    safe_join([
      content_tag('optgroup', dept_options,                                                                    label: l('label_department_plural')),
      content_tag('optgroup', options_for_select(Group.givable.map { |g| [g.to_s, "Group:#{g.id}"] }, selected), label: l(:label_group_plural)),
      content_tag('optgroup', options_for_select(Role.givable.map  { |r| [r.to_s, "Role:#{r.id}"]  }, selected), label: l(:label_role_plural))
    ])
  end
end
