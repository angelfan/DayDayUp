# coding: utf-8
require File.dirname(__FILE__) + '/browser'

class Config
  attr_reader :forbids, :exclusions, :redirect_to

  def initialize
    @forbids = []
    @exclusions = []
    @redirect_to = nil
  end

  def forbid(name)
    @forbids << Browser.new(name)
  end

  def exclude(path)
    @exclusions << path
  end

  def redirect(url)
    @exclusions << url
    @redirect_to = url
  end

  def excluded?(path)
    @exclusions.any? do |exclusion|
      case exclusion
      when String
        exclusion == path
      when Regexp
        exclusion =~ path
      end
    end
  end
end
