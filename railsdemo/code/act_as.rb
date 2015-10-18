module ActiveRecord
  module Acts #:nodoc:
    module Cache #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_cache(options = {})
          klass = options[:class_name] || "#{name}Cache".constantize
          options[:delegate] ||= []

          class_eval <<-EOV
            def acts_as_cache_class
              ::#{klass}
            end

            after_commit :create_cache, :if => :persisted?
            after_commit :destroy_cache, on: :destroy

            if #{options[:delegate]}.any?
              delegate *#{options[:delegate]}, to: :cache
            end

            include ::ActiveRecord::Acts::Cache::InstanceMethods
          EOV
        end
      end

      module InstanceMethods
        def create_cache
          acts_as_cache_class.create(self)
        end

        def destroy_cache
          acts_as_cache_class.destroy(self)
        end

        def cache
          acts_as_cache_class.find_or_create_cache(id)
        end
      end
    end
  end
end

class User < ActiveRecord::Base
  acts_as_cache
end

class Project < ActiveRecord::Base
  acts_as_cache
end
