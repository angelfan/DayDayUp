# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/../../lib/moving/drive'

describe Moving::Driver do
  before do
    @driver = Moving::Driver.new(5, 5)
  end

  describe '#move' do
    it 'move with direction is N' do
      @driver.move('N')
      @driver.x.must_equal 5
      @driver.y.must_equal 6
    end

    it 'move with direction is S' do
      @driver.move('S')
      @driver.x.must_equal 5
      @driver.y.must_equal 4
    end

    it 'move with direction is W' do
      @driver.move('W')
      @driver.x.must_equal 4
      @driver.y.must_equal 5
    end

    it 'move with direction is E' do
      @driver.move('E')
      @driver.x.must_equal 6
      @driver.y.must_equal 5
    end
  end
end
