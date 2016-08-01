# redmine


```shell
rake redmine:plugins:test
bundle exec ruby bin/rails generate redmine_plugin <plugin_name>
bundle exec ruby bin/rails generate redmine_plugin_controller <plugin_name> <controller_name> [action_name]
```

## init
```ruby
# init
# require 'plugin_name' 如果有一些文件放在lib下

Redmine::Plugin.register :plugin_name do
  menu :admin_menu, :name, {:controller => 'c', :action => 'a'}, :caption => :name
end
```

```ruby
# lib/plugin_name.rb

Rails.configuration.to_prepare do
  require_dependency 'plugin_name/xxx'
end

module PluginName
  def xxx
    # setting
    # available_permissions
    # others
  end
end
```

## hook
```ruby
# lib/plugin_name/hooks/xx_hook.rb

class MyHook < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, :partial => "show_more_data"

  def some_hook_name(context={})
    return stylesheet_link_tag(:plugin_name, :plugin => 'plugin_name')
  end
end

class MultipleHook < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom,
    {:partial => "show_more_data"},
    {:partial => "show_even_more_data"}
end
```

## patch
```ruby
# lib/plugin_name/patches/xxx_patch.rb

module PluginName
  module Patches
    module UsersControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          before_filter :authorize_people, :only => :show
        end
      end

      module InstanceMethods
        def authorize_people
          deny_access unless User.current.allowed_people_to?(:view_people, @user)
        end

      end
    end
  end
end

unless UsersController.included_modules.include?(PluginName::Patches::UsersControllerPatch)
  UsersController.send(:include, PluginName::Patches::UsersControllerPatch)
end


require_dependency 'application_helper'

module PluginName
  module Patches
    module ApplicationHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :link_to_user, :people
          alias_method_chain :avatar, :people
        end
      end


      module InstanceMethods
        def avatar_with_people(user, options = { })
        end

        def link_to_user_with_people(user, options={})
        end
      end
    end
  end
end

unless ApplicationHelper.included_modules.include?(PluginName::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, PluginName::Patches::ApplicationHelperPatch)
end
```

## helper
```ruby
# lib/plugin_name/helpers/redmine_people.rb

module PluginName
  module Helper

    def xxx()
    end
  end
end

ActionView::Base.send :include, PluginName::Helper
```

## fetcher
```ruby
```

## others
```ruby
def menu(menu, item, url, options={})
  Redmine::MenuManager.map(menu).push(item, url, options)
end

alias :add_menu_item :menu


Redmine::Hook::ViewListener
```


