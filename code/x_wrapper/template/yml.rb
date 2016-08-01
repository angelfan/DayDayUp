require 'yaml'

module XWrapper
  module Template
    module Yml
      extend ActiveSupport::Concern

      module ClassMethods
        def all
          data = YAML.load_file("#{name.pluralize}.yml")
          data.map { |d| new(d) }
        end

        def wrapper_attrs(*names)
          @attributes = names

          class_eval do
            attr_accessor *names

            define_method(:initialize) do |values = {}|
              names.each do |name|
                instance_variable_set('@' + name.to_s, values[name.to_s])
              end
            end
          end
        end
      end
    end
  end
end
