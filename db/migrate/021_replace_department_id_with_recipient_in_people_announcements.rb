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

class ReplaceDepartmentIdWithRecipientInPeopleAnnouncements < ActiveRecord::Migration[4.2]
  def up
    add_column :people_announcements, :recipient_id, :integer
    add_column :people_announcements, :recipient_type, :string

    execute <<-SQL
      UPDATE people_announcements 
      SET recipient_id = department_id,
          recipient_type = 'Department'
      WHERE department_id IS NOT NULL
    SQL

    add_index :people_announcements, :recipient_id

    remove_column :people_announcements, :department_id
  end

  def down
    add_column :people_announcements, :department_id, :integer

    execute <<-SQL
      UPDATE people_announcements 
      SET department_id = recipient_id
      WHERE recipient_type = 'Department'
    SQL
    
    remove_index :people_announcements, :recipient_id

    remove_column :people_announcements, :recipient_id
    remove_column :people_announcements, :recipient_type
  end
end
