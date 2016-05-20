class Notifier
  attr_accessor :subscribes

  def initialize
    @subscribes = Hash.new { |hash, key| hash[key] = [] }
  end

  def publish(event, payload)
    event = event.to_sym
    @subscribes[event].each do |sub|
      next unless sub.respond_to?(event)
      sub.send(event, payload) if payload
    end
  end

  def subscribe(event, subscriber)
    @subscribes[event.to_sym] << subscriber
  end
end

module Notifications
  class << self
    attr_accessor :notifier

    def publish(event, payload = {})
      notifier.publish(event, payload)
    end

    def subscribe(event, subscriber)
      notifier.subscribe(event, subscriber)
    end
  end

  self.notifier = Notifier.new
end
