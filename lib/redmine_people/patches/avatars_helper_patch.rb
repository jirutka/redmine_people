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

module RedminePeople
  module Patches
    module AvatarsHelperPatch
      def avatar(user, options = {})
        options[:size] ||= GravatarHelper::DEFAULT_OPTIONS[:size]
        size2x = options[:size].to_i*2
        if user.blank? || user.is_a?(String) || (user.is_a?(User) && user.anonymous?)
          return super(user, options)
        end
        if user.is_a?(User) && (avatar = user.avatar)
          avatar_url = url_for protocol: Setting.protocol, only_path: true, controller: '/people', action: 'avatar', id: avatar, size: options[:size]
          options[:srcset] = url_for(protocol: Setting.protocol, only_path: true, controller: '/people', action: 'avatar', id: avatar, size: size2x) + " 2x"
          image_tag(avatar_url, options.merge(class: "avatar gravatar #{'without-margin' if !Setting.gravatar_enabled?}"))
        elsif user.respond_to?(:twitter) && !user.twitter.blank?
          image_tag("https://twitter.com/#{user.twitter}/profile_image?size=original", options.merge(:class => 'gravatar'))
        elsif !Setting.gravatar_enabled?
          image_tag('person.png', options.merge(:plugin => 'redmine_people', :class => "gravatar #{'without-margin'}"))
        else
          super(user, options)
        end
      end
    end
  end
end

if RedminePeople.module_exists?(:AvatarsHelper)
  AvatarsHelper.prepend(RedminePeople::Patches::AvatarsHelperPatch)
end
