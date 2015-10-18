# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__)+'/mower'

describe Mower do
  before do
    @mower = Mower.new(1, 2, 'N')
  end

  it 'initialize class: Meadow' do
    @mower.x.must_equal 1
    @mower.y.must_equal 2
    @mower.direction.must_equal 'N'
  end

  it 'location' do
    @mower.location.must_equal "1 2 N"
  end

  it 'turn_left' do
    @mower.l.must_equal 'W'
    @mower.l.must_equal 'S'
    @mower.l.must_equal 'E'
    @mower.l.must_equal 'N'
  end

  it 'turn_right' do
    @mower.r.must_equal 'E'
    @mower.r.must_equal 'S'
    @mower.r.must_equal 'W'
    @mower.r.must_equal 'N'
  end

  it 'move with location is 1 2 N' do
    @mower.m
    @mower.x.must_equal 1
    @mower.y.must_equal 3
  end

  it 'move with direction is 1 2 W' do
    @mower.direction = 'W'
    @mower.m
    @mower.x.must_equal 0
    @mower.y.must_equal 2
  end

  it 'move with direction is 1 2 S' do
    @mower.direction = 'S'
    @mower.m
    @mower.x.must_equal 1
    @mower.y.must_equal 1
  end

  it 'move with direction is 1 2 E' do
    @mower.direction = 'E'
    @mower.m
    @mower.x.must_equal 2
    @mower.y.must_equal 2
  end

end