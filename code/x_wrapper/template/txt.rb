module XWrapper
  module Template
    module Txt
      extend ActiveSupport::Concern

      module ClassMethods
        def _headers_
          file = File.new("#{name.pluralize}.txt")
          headers = file.gets.chomp.split(',')
          file.close
          headers
        end

        def all
          file = File.new("#{name.pluralize}.txt")
          file.gets
          records = file.map do |line|
            new(line.chomp.split(',').map(&:strip))
          end
          file.close
          records
        end

        def wrapper_attrs(*names)
          @attributes = names

          class_eval do
            attr_accessor *names

            define_method(:initialize) do |values|
              names.each do |name|
                instance_variable_set('@' + name.to_s, values[self.class._headers_.index(name.to_s)])
              end
            end
          end
        end
      end
    end
  end
end
