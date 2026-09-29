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

require File.expand_path('../../test_helper', __FILE__)

class MailerTest < ActiveSupport::TestCase
  include RedminePeople::TestCase::TestHelper

  fixtures :issues,
           :issue_statuses,
           :enumerations,
           :users,
           :projects,
           :enabled_modules,
           :trackers,
           :projects_trackers,
           :roles,
           :members,
           :member_roles,
           :email_addresses,
           :user_preferences

  load_plugin_fixtures :redmine_people,
                       :people_information

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.plain_text_mail = '0'
    Setting.default_language = 'en'
    User.current = nil
  end

  def test_issue_edit_should_notify_mentioned_people_in_notes
    User.find(1).mail_notification = 'only_my_events'

    journal = Journal.generate!(journalized: Issue.find(3), user: User.find(1), notes: 'Hello @admin.')

    ActionMailer::Base.deliveries.clear
    Mailer.deliver_issue_edit(journal)

    # @jsmith and @dlopper are members of the project
    # admin is mentioned in the notes
    # @dlopper won't receive duplicated notifications
    assert_equal 3, ActionMailer::Base.deliveries.size
    assert_include User.find(1).mail, ActionMailer::Base.deliveries.map(&:to).flatten.sort
  end
end
