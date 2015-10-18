# coding: utf-8
require 'minitest/autorun'
require File.dirname(__FILE__) + '/work'

describe Work do
  before do
    @work = Work.new
    @meadow = @work.init_meadow(5, 5)
    @mower = @work.init_mower(1, 2, 'N')
  end

  it 'start mowing right route 1' do
    route = %w(L M L M L M L M M)
    @work.start(route)
    @mower.location.must_equal '1 3 N'
  end

  it 'start mowing right route 2' do
    route = %w(L M L M L M L M M R M)
    @work.start(route)
    @mower.location.must_equal '2 3 E'
  end

  it 'start mowing wrong route(not legitimate)' do
    route = %w(L M L G)
    @work.start(route)
    @work.error_msg[0].must_equal '割草路径不合法'
  end

  it 'start mowing wrong with rout out of range 1' do
    route = %w(L M L M L M L M M M M M)
    @work.start(route)
    @work.error_msg[0].must_equal '割草路径超出范围'
  end

  it 'start mowing wrong with rout out of range 2 (latest location is in range)' do
    route = %w(M M M M M M L L M M)
    @work.start(route)
    @work.error_msg[0].must_equal '割草路径超出范围'
  end

  it 'start mowing wrong with rout out of range 3 (fix a bug with turn right)' do
    route = %w(M M R M M M M M)
    @work.start(route)
    @work.error_msg[0].must_equal '割草路径超出范围'
  end

  it 'start mowing wrong with rout out of range 3 (modify when out of range error msg prompted only once)' do
    route = %w(M M R M M M M M)
    @work.start(route)
    @work.error_msg[0].must_equal '割草路径超出范围'
  end

  it 'init mower with wrong' do
    new_work = Work.new
    new_work.init_meadow(5, 5)
    new_work.init_mower(6, 2, 'L')
    new_work.error_msg[0].must_equal '割草机开始坐标不能超出草地范围'
    new_work.error_msg[1].must_equal '割草机面朝方向必须是东(E)西(W)南(S)北(N)'
  end
end
