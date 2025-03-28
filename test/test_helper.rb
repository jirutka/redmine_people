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

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class RedminePeople::TestCase
  include ActionDispatch::TestProcess

  module TestHelper
    def with_people_settings(options, &block)
      base_classes = [Symbol, false, true, nil, Integer]
      # base_classes << Fixnum if RUBY_VERSION < '3.2.2'
      saved_settings = options.keys.inject({}) do |h, k|
        h[k] = case Setting.plugin_redmine_people[k]
          when *base_classes
            Setting.plugin_redmine_people[k]
          else
            Setting.plugin_redmine_people[k].dup
          end
        h
      end
      settings = Setting.plugin_redmine_people
      Setting.plugin_redmine_people = settings.merge(options)
      yield
    ensure
      saved_settings.each { |k, v| Setting.plugin_redmine_people[k] = v } if saved_settings
    end

    def people_uploaded_file(filename, mime)
      file_path = "plugins/redmine_people/test/fixtures/files/#{filename}"
      fixture_file_upload(Redmine::VERSION.to_s < '4' ? "../../#{file_path}" : File.join(Rails.root, file_path), mime, true)
    end

    def compatible_request(type, action, parameters = {})
      send(type, action, :params => parameters)
    end

    def compatible_xhr_request(type, action, parameters = {})
      send(type, action, :params => parameters, :xhr => true)
    end

    def people_in_list
      ids = css_select('table.people #ids_').map { |tag| tag['text'].to_i }
      Person.where(:id => ids).sort_by { |person| ids.index(person.id) }
    end

    def announcements_in_list
      descriptions = css_select('table.list td.name').map { |tag| tag['text'] }
      PeopleAnnouncement.where(:description => descriptions)
    end
  end

  def self.create_fixtures(fixtures_directory, table_names, class_names = {})
    ActiveRecord::FixtureSet.create_fixtures(fixtures_directory, table_names, class_names = {})
  end
end
