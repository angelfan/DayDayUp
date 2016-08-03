# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/../../lib/config'

describe Config do
  before do
    @config = Config.new
  end

  it '#forbid' do
    @config.forbid 'Firefox'
    @config.forbids.map(&:name).must_equal ['firefox']
  end

  it '#exclude' do
    @config.exclude %r{^/assets}
    @config.exclusions.must_equal [/^\/assets/]
  end

  it '#redirect' do
    @config.redirect '/forbid_request'
    @config.redirect_to.must_equal '/forbid_request'
  end

  it '#excluded?' do
    @config.exclude '/users/sign_in'
    @config.exclude %r{^/assets}

    @config.excluded?('/users/sign_in').must_equal true
    @config.excluded?('/assets/xx.js').must_equal true
  end
end
