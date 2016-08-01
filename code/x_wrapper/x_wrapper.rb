require 'active_support/core_ext/string'
require 'active_support/core_ext/module/delegation'
require 'active_support/concern'

require File.dirname(__FILE__) + '/template/yml'
require File.dirname(__FILE__) + '/template/txt'

module XWrapper
  extend ActiveSupport::Concern

  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      include Enumerable
      delegate :each, :size, to: :all

      def all
        fail 'Not yet implemented.'
      end

      def wrapper_attrs
        fail 'Not yet implemented.'
      end

      def attributes
        @attributes
      end

      def find_by(attr, value)
        find { |record| record.send(attr) == value }
      end
    end
  end

  module Yml
    extend ActiveSupport::Concern
    include Base
    include Template::Yml
  end

  module Txt
    extend ActiveSupport::Concern
    include Base
    include Template::Txt
  end
end

class User
  include XWrapper::Yml
  wrapper_attrs :id, :name
end

class Product
  include XWrapper::Txt
  wrapper_attrs :id, :name, :country, :price

  def info
    "#{name}: #{price}"
  end
end

p User.all
p Product.first.info
