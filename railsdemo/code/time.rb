def get_month
  case Time.now.month
  when 1..9
    Time.now.month.to_s
  when 10
    'A'
  when 11
    'B'
  when 12
    'C'
  end
end

def get_day
  series = ('A'..'Z').to_a
  case Time.now.day
  when 1..9
    Time.now.day.to_s
  else
    series[Time.now.day - 10]
  end
end
