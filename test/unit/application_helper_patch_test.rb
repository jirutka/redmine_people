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

class ApplicationHelperPatchTest < Redmine::HelperTest
  fixtures :users, :email_addresses

  load_plugin_fixtures :redmine_people, :people_information

  def setup
    User.current = User.find(1)
  end

  def test_link_to_user_with_format_option_should_not_raise
    assert_nothing_raised do
      view.link_to_user(User.find(1), :format => :username)
    end
  end

  def test_link_to_user_with_format_option_should_link_to_person
    link = view.link_to_user(User.find(1), :format => :username)
    assert_match %r{href="[^"]*/people/1"}, link
  end
end
