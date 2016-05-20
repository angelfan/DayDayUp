# coding: utf-8
require File.dirname(__FILE__) + '/validator'

module Moving
  class Driver
    include Moving::Validator
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def location
      [x, y]
    end

    def move(direction, step = 1)
      validator_direction(direction)
      send("move_to_#{direction.downcase}", step)
    end

    private

    def move_to_n(step)
      @y += step
    end

    def move_to_w(step)
      @x -= step
    end

    def move_to_s(step)
      @y -= step
    end

    def move_to_e(step)
      @x += step
    end
  end
end
