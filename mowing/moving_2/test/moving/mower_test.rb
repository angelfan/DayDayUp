# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/../../lib/moving/mower'
require File.dirname(__FILE__) + '/../../lib/moving/direction_ctrl'
require File.dirname(__FILE__) + '/../../lib/moving/drive'

describe Moving::Mower do
  before do
    @mower = Moving::Mower.new(Moving::Driver.new(5, 5), Moving::DirectionCtrl.new('N'))
  end

  it '#l' do
    @mower.l
    @mower.send(:current_direction).name.must_equal 'W'
  end

  it '#r' do
    @mower.r
    @mower.send(:current_direction).name.must_equal 'E'
  end

  it '#m, move towards north' do
    @mower.m
    @mower.coordinate[:x].must_equal 5
    @mower.coordinate[:y].must_equal 6
  end
end
