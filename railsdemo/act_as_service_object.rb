require 'active_support/all'


module ActAsServiceObject
  extend ActiveSupport::Concern
  include ActiveSupport::Rescuable
  # include ActiveRecord::Validation

  module ClassMethods
    def call(args= {})
      service = new(args)
      if service.valid?
        SuccessResponse.new(new(args).call)
      else
        ErrorResponse.new(service.errors)
      end
    rescue => e
      if self.rescue_handlers.map(&:first).include?(e.class.name)
        return ErrorResponse.new(service.rescue_with_handler(e))
      end
      fail e
    end
  end

  def rescue_with_handler(exception)
    if handler = handler_for_rescue(exception)
      handler.arity != 0 ? handler.call(exception) : handler.call
    end
  end

  def valid?
    return true
  end

  class SuccessResponse
    attr_reader :success, :payload

    def initialize(args)
      if args.is_a?(Hash)
        @success = args.delete(:success) || true
        @payload = args.delete(:payload) || args
      else
        @success = true
        @payload = args
      end
    end

    def errors
      nil
    end
  end

  class ErrorResponse
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def success?
      false
    end

    def payload
      errors
    end
  end
end

class UploadInventoryService


  include ActAsServiceObject
  rescue_from StandardError, with: :standard_error
  rescue_from 'UploadInventoryService::MyError' do |e|
    e.message
  end

  attr_accessor :inventory

  def initialize(args = {})
    @inventory = args.fetch(:inventory)
  end

  def call
    # fail StandardError
    fail MyError
  end

  private

  def standard_error
    'standard_error'
  end

  class MyError < StandardError
  end
end

# p UploadInventoryService.new.rescue_with_handler(StandardError.new)
p UploadInventoryService.call(inventory: 1).errors
# p UploadInventoryService.rescue_handlers.map(&:first).map(&:constantize).uniq.join(',')
