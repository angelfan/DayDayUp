# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/../forbid_browser'

describe ForbidBrowser do
  before do
    @app = Minitest::Mock.new
    @app.expect :call, [200, 'head', 'body'], [Hash]
  end

  it 'OK' do
    forbid_browser = ForbidBrowser.new(@app) do |config|
      config.forbid 'Firefox'
      config.exclude '/users/sign_in'
      config.redirect '/forbid_request'
    end
    env = {
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0',
      'REQUEST_PATH' => '/users/sign_in'
    }
    forbid_browser.call(env).must_equal [200, 'head', 'body']
  end

  it '302' do
    forbid_browser = ForbidBrowser.new(@app) do |config|
      config.forbid 'Firefox'
      config.redirect '/forbid_request'
    end
    env = { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0' }
    forbid_browser.call(env).must_equal [302, { 'Location' => '/forbid_request' }, []]
  end

  it '400' do
    forbid_browser = ForbidBrowser.new(@app) do |config|
      config.forbid 'Firefox'
      config.exclude '/users/sign_in'
    end
    env = { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0' }
    forbid_browser.call(env).must_equal [400, { 'Content-Type' => 'text/plain' }, []]
  end
end
