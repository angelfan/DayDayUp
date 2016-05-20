# coding: utf-8
module Moving
  class Mower
    attr_accessor :driver, :direction_ctrl

    def initialize(driver, direction_ctrl)
      @direction_ctrl = direction_ctrl
      @driver = driver
    end

    def l
      direction_ctrl.turn_left
    end

    def r
      direction_ctrl.turn_right
    end

    def m
      driver.move(direction_ctrl.current_direction.name)
    end

    def start(route)
      route.each do |med|
        public_send(med.downcase)
      end
    end

    def current_location
      {coordinate: coordinate, direction: current_direction}
    end

    def coordinate
      {x: x, y: y}
    end

    private

    def x
      driver.x
    end

    def y
      driver.y
    end

    def current_direction
      direction_ctrl.current_direction
    end
  end
end