# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/meadow'

describe Meadow do
  before do
    @meadow = Meadow.new(5, 5)
  end

  it 'init the class successfully' do
    @meadow.x.must_equal 5
    @meadow.y.must_equal 5
  end
end
