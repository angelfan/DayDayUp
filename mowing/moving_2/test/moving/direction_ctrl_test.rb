# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/../../lib/moving/direction_ctrl'

describe Moving::DirectionCtrl do
  before do
    @direction_ctrl = Moving::DirectionCtrl.new('N')
  end

  it '#current_direction=' do
    @direction_ctrl.current_direction=('N')
    @direction_ctrl.current_direction.name.must_equal 'N'
  end

  it 'turn left form north' do
    @direction_ctrl.turn_left
    @direction_ctrl.current_direction.name.must_equal 'W'
    @direction_ctrl.turn_left
    @direction_ctrl.current_direction.name.must_equal 'S'
    @direction_ctrl.turn_left
    @direction_ctrl.current_direction.name.must_equal 'E'
    @direction_ctrl.turn_left
    @direction_ctrl.current_direction.name.must_equal 'N'
  end

  it 'turn left form north' do
    @direction_ctrl.turn_right
    @direction_ctrl.current_direction.name.must_equal 'E'
    @direction_ctrl.turn_right
    @direction_ctrl.current_direction.name.must_equal 'S'
    @direction_ctrl.turn_right
    @direction_ctrl.current_direction.name.must_equal 'W'
    @direction_ctrl.turn_right
    @direction_ctrl.current_direction.name.must_equal 'N'
  end
end
