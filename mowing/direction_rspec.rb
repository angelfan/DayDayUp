# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__)+'/direction'


describe DirectionCtrl do
  before do
    @direction_ctrl = DirectionCtrl.new('N')
  end

  it 'get node within %w(N W W S E)' do
    @direction_ctrl.get_node('N').element.must_equal 'N'
    @direction_ctrl.get_node('W').element.must_equal 'W'
    @direction_ctrl.get_node('S').element.must_equal 'S'
    @direction_ctrl.get_node('E').element.must_equal 'E'
  end

  it 'turn left form north' do
    @direction_ctrl.turn_left.must_equal 'W'
    @direction_ctrl.turn_left.must_equal 'S'
    @direction_ctrl.turn_left.must_equal 'E'
    @direction_ctrl.turn_left.must_equal 'N'
  end

  it 'turn right form north' do
    @direction_ctrl.turn_right.must_equal 'E'
    @direction_ctrl.turn_right.must_equal 'S'
    @direction_ctrl.turn_right.must_equal 'W'
    @direction_ctrl.turn_right.must_equal 'N'
  end


end