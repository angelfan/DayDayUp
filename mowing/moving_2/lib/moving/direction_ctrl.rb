# coding: utf-8
require File.dirname(__FILE__) + '/validator'

module Moving
  class DirectionCtrl
    include Moving::Validator
    attr_accessor :directions
    attr_reader :current_direction

    def initialize(direction)
      validator_direction direction
      @north = Node.new('N')
      @south = Node.new('S')
      @west = Node.new('W')
      @east = Node.new('E')
      @north.left = @west
      @north.right = @east
      @south.left = @east
      @south.right = @west
      @west.left = @south
      @west.right = @north
      @east.left = @north
      @east.right = @south

      @current_direction = @north
      @directions = { n: @north, s: @south, w: @west, e: @east }
    end

    def current_direction=(direction)
      @current_direction = directions.fetch("#{direction.downcase}".to_sym)
    end

    def turn_left
      @current_direction = current_direction.left
    end

    def turn_right
      @current_direction = current_direction.right
    end

    class Node
      attr_reader :name
      attr_accessor :left, :right

      def initialize(name)
        @name = name
        @left = nil
        @right = nil
      end
    end
  end
end
