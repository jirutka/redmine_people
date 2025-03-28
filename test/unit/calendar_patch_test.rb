# encoding: utf-8
#
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

require File.expand_path('../../test_helper', __FILE__)

class CalendarPatchTest < ActiveSupport::TestCase
  RedminePeople::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_people).directory + '/test/fixtures/', [:people_holidays])

  def setup
    @calendar1 = Redmine::Helpers::Calendar.new('2017-01-01'.to_date)
    @calendar2 = Redmine::Helpers::Calendar.new('2017-01-01'.to_date)
    birthday = PeopleInformation.find(1)
    birthday.update_attribute(:birthday, '2017-01-02')

    @calendar1.custom_events = PeopleHoliday.between('2017-01-01'.to_date, '2018-01-01'.to_date).to_a
    @calendar2.custom_events = [PeopleInformation.find(1)]
  end
end
