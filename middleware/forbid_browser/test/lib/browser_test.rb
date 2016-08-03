# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/../../lib/browser'

describe Browser do
  before do
    @browser = Browser.new('firefox')
  end

  it 'forbid' do
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0'
    @browser.forbid?(user_agent).nil?.must_equal false
  end

  it 'not forbid' do
    user_agent = '"Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Mobile Safari/537.36"'
    @browser.forbid?(user_agent).nil?.must_equal true
  end
end
