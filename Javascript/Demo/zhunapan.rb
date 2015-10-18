# 大转盘需要调用的action: 返回json数据，给js调用
# params: site_page_id, key
def zhuanpan_json
  # status 值：
  # 0 -> 亲，活动还未开始啦!
  # 1 -> 活动进行中: 抽奖并中奖
  # 2 -> 活动进行中：抽奖未中奖
  # 3 -> 今日奖品已经领完，明天继续哦！
  # 4 -> 亲，活动已经结束啦!
  @site_page = SitePage.find(params[:id])

  # 状态获取
  status = case SitePageKeystore.value_for(@site_page, 'open_toggle')
           when '活动进行中'
             2
           when '活动未开始'
             0
           when '活动已结束'
             4
           else
             2
           end

  # 获取用户设定的奖品总数
  prize_obj = SitePageKeystore.get(@site_page.id, 'prize_count')
  prize_count = prize_obj.value.to_i || 50

  # 获取预计抽奖人数
  person_obj = SitePageKeystore.get(@site_page.id, 'person_count')
  person_count = person_obj.value.to_i || 100

  # 计算中奖概率
  rate = prize_count / (person_count + 0.1)

  # 获取已抽奖次数
  zhuan_obj = SitePageKeystore.get(@site_page.id, 'zhuan_count')
  if zhuan_obj.nil?
    key = CommonKey.get('zhuan_count')
    CommonKey.put('zhuan_count', 0) if key.nil?
    SitePageKeystore.put(@site_page.id, 'zhuan_count', 0)
    zhuan_obj = SitePageKeystore.get(@site_page.id, 'zhuan_count')
  end
  zhuan_count = zhuan_obj.value.to_i
  SitePageKeystore.put(@site_page.id, 'zhuan_count', zhuan_count + 1)

  status = 4 if zhuan_count >= person_count # 次数已经抽完

  # 获取中奖次数
  coupon_obj = SitePageKeystore.get(@site_page.id, 'coupon_count')
  if coupon_obj.nil?
    key = CommonKey.get('coupon_count')
    CommonKey.put('coupon_count', 0) if key.nil?
    SitePageKeystore.put(@site_page.id, 'coupon_count', 0)
    coupon_obj = SitePageKeystore.get(@site_page.id, 'coupon_count')
  end
  coupon_count = coupon_obj.value.to_i

  status = 3 if coupon_count >= prize_count && status != 4 # 奖品已完

  # 奖项数组
  # 是一个二维数组，记录了所有本次抽奖的奖项信息，
  # 其中id表示中奖等级，prize表示奖品，v表示中奖概率。
  # 注意其中的v必须为整数，你可以将对应的 奖项的v设置成0，即意味着该奖项抽中的几率是0，
  # 数组中v的总和（基数），基数越大越能体现概率的准确性。
  # 本例中v的总和为100，那么平板电脑对应的 中奖概率就是1%，
  # 如果v的总和是10000，那中奖概率就是万分之一了。

  # goods_id:
  # 8个值分别对应8格转盘的8个格子，其中3，7格为默认未中奖格，其他格为有奖格
  # 1 -> 奖品1
  # 2 -> 奖品2
  # 3 -> 未中奖
  # 4 -> 奖品3
  # 5 -> 奖品4
  # 6 -> 奖品5
  # 7 -> 未中奖
  # 8 -> 奖品6
  failed_count = (50 / rate).to_i - 50 # 预设中奖个数为50， 则根据中奖概率计算出未中奖个数
  prize_hash = {
    0 => { 'id' => 1, 'prize' => SitePageKeystore.value_for(@site_page, 'good1'), 'v' => 1 },
    1 => { 'id' => 2, 'prize' => SitePageKeystore.value_for(@site_page, 'good2'), 'v' => 2 },
    2 => { 'id' => 8, 'prize' => SitePageKeystore.value_for(@site_page, 'good3'), 'v' => 5 },
    3 => { 'id' => 4, 'prize' => SitePageKeystore.value_for(@site_page, 'good4'), 'v' => 10 },
    4 => { 'id' => 5, 'prize' => SitePageKeystore.value_for(@site_page, 'good5'), 'v' => 12 },
    5 => { 'id' => 6, 'prize' => SitePageKeystore.value_for(@site_page, 'good6'), 'v' => 20 },
    6 => { 'id' => 3, 'prize' => '没有抽中，感谢参与', 'v' => failed_count / 3 },
    7 => { 'id' => 7, 'prize' => '没有抽中，没准下次能抽到哦', 'v' => failed_count / 3 * 2 }
  }

  # 每次前端页面的请求，PHP循环奖项设置数组，
  # 通过概率计算函数get_rand获取抽中的奖项id。
  # 将中奖奖品保存在数组$res['yes']中，
  # 而剩下的未中奖的信息保存在$res['no']中，
  # 最后输出json个数数据给前端页面。
  arr = {}
  prize_hash.each_pair do |_key, val|
    arr[val['id']] = val['v']
  end
  rid = get_rand(arr) # 根据概率获取奖项id
  coupon = prize_hash[rid - 1] # 抽中的奖项
  if status == 2 && ![3, 7].include?(coupon['id']) # 中奖了
    SitePageKeystore.put(@site_page.id, 'coupon_count', coupon_count + 1)
    status = 1
  end

  if status == 1 # 中奖了
    render json: { status: status, goods_id: coupon['id'], message: coupon['prize'], Coupon: { grade: coupon['id'] } }
  else # 没中奖
    render json: { status: status }
  end
end

#
#  经典的概率算法，
#  $proArr是一个预先设置的数组，
#  假设数组为：array(100,200,300，400)，
#  开始是从1,1000 这个概率范围内筛选第一个数是否在他的出现概率范围之内，
#  如果不在，则将概率空间，也就是k的值减去刚刚的那个数字的概率空间，
#  在本例当中就是减去100，也就是说第二个数是在1，900这个范围内筛选的。
#  这样 筛选到最终，总会有一个数满足要求。
#  就相当于去一个箱子里摸东西，
#  第一个不是，第二个不是，第三个还不是，那最后一个一定是。
#  pro_hash = {id => v, 1 => 1, 2 => 30}
def get_rand(pro_hash)
  result = nil
  # 概率数组的总概率精度
  pro_sum = pro_hash.values.inject { |sum, x| sum + x }
  # 概率数组循环
  pro_hash.each_pair do |key, pro_cur|
    rand_num = 1 + rand(pro_sum)
    if rand_num <= pro_cur
      result = key
      break
    else
      pro_sum -= pro_cur
    end
  end
  result
end
