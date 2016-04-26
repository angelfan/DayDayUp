critics = { 'Lisa Rose' => { 'Lady in the Water' => 2.5,
                             'Snakes on a Plane' => 3.5,
                             'Just My Luck' => 3.0,
                             'Superman Returns' => 3.5,
                             'You, Me and Dupree' => 2.5,
                             'The Night Listener' => 3.0 },
            'Gene Seymour' => { 'Lady in the Water' => 3.0,
                                'Snakes on a Plane' => 3.5,
                                'Just My Luck' => 1.5,
                                'Superman Returns' => 5.0,
                                'The Night Listener' => 3.0,
                                'You, Me and Dupree' => 3.5 },
            'Michael Phillips' => { 'Lady in the Water' => 2.5,
                                    'Snakes on a Plane' => 3.0,
                                    'Superman Returns' => 3.5,
                                    'The Night Listener' => 4.0 },
            'Claudia Puig' => { 'Snakes on a Plane' => 3.5,
                                'Just My Luck' => 3.0,
                                'The Night Listener' => 4.5,
                                'Superman Returns' => 4.0,
                                'You, Me and Dupree' => 2.5 },
            'Mick LaSalle' => { 'Lady in the Water' => 3.0,
                                'Snakes on a Plane' => 4.0,
                                'Just My Luck' => 2.0,
                                'Superman Returns' => 3.0,
                                'The Night Listener' => 3.0,
                                'You, Me and Dupree' => 2.0 },
            'Jack Matthews' => { 'Lady in the Water' => 3.0,
                                 'Snakes on a Plane' => 4.0,
                                 'The Night Listener' => 3.0,
                                 'Superman Returns' => 5.0,
                                 'You, Me and Dupree' => 3.5 },
            'Toby' => { 'Snakes on a Plane' => 4.5,
                        'You, Me and Dupree' => 1.0,
                        'Superman Returns' => 4.0 },
            'Lisa Rose Like' => { 'Lady in the Water' => 3.5,
                                  'Snakes on a Plane' => 4.5,
                                  'Just My Luck' => 4.0,
                                  'Superman Returns' => 4.2 } }
# 皮尔逊相关度评价
def sim_pearson(prefs, p1, p2)
  si = []
  # 得到双方都评价过的列表
  prefs[p1].keys.each do |item|
    si << item if (prefs[p2]).include?(item)
  end

  # 如果没有则返回0
  n = si.size
  return 0 if n == 0

  # 对所有偏好求和
  sum1 = si.map { |it| prefs[p1][it] }.reduce(&:+)
  sum2 = si.map { |it| prefs[p2][it] }.reduce(&:+)

  # 求平方和
  sum1Sq = si.map { |it| prefs[p1][it]**2 }.reduce(&:+)
  sum2Sq = si.map { |it| prefs[p2][it]**2 }.reduce(&:+)

  # 求乘积之和
  pSum = si.map { |it| prefs[p1][it] * prefs[p2][it] }.reduce(&:+)

  # 计算皮尔逊评价值
  num = pSum - (sum1 * sum2 / n)
  den = ((sum1Sq - sum1**2 / n) * (sum2Sq - sum2**2 / n))**(1.0 / 2)
  return 0 if den == 0
  num / den
end

sim_pearson(critics, 'Lisa Rose', 'Gene Seymour') # 0.396059017191
sim_pearson(critics, 'Lisa Rose', 'Lisa Rose Like') # 0.9525626715469733

# 欧几里得距离评价
def sim_distance(prefs, p1, p2)
  si = []
  # 得到双方都评价过的列表
  prefs[p1].keys.each do |item|
    si << item if (prefs[p2]).include?(item)
  end

  # 如果没有则返回0
  return 0 if si.size == 0

  # 计算所有差值平方和
  sum_of_squares = si.map do |item|
    (prefs[p1][item]-prefs[p2][item]) ** 2
  end.reduce(&:+)

  1/(1+sum_of_squares ** (1.0/2))
end

sim_distance(critics, 'Lisa Rose', 'Gene Seymour') # 0.29429805508554946
sim_distance(critics, 'Lisa Rose', 'Lisa Rose Like') # 0.34865629286222505

# 为评论者打分
def topMatches(prefs,person,n=5, similarity= :sim_pearson)
  scores = []
  prefs.keys.each do |other|
    scores << [send(similarity, prefs, person, other), other] if other != person
  end
  scores.sort! { |x, y| y[0] <=>  x[0] }
  scores[0..(n-1)]
end

topMatches(critics, 'Toby', 3)
# [[0.99999999999994, "Lisa Rose Like"], [0.9912407071619299, "Lisa Rose"], [0.9244734516419049, "Mick LaSalle"]]