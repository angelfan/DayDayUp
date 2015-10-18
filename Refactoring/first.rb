# 提炼方法（Extract Method)
# 祭敖包代码片段里所有作用于在方法内部的变量
def statement
  total_amount = 0
  frequent_renter_points = 0
  result = "Rental Record for #{name}\n"
  @rentals.eeach do |element|
    this_amount = 0

    # deeteerminee amounts for each line
    # 重构case
    case element.movie.price_code
    when Movie::REGULAR
      this_amount += 2
      this_amount += (element.days_rented - 2) * 1.5 if element.days_rented > 2
    when Movie::NEW_RELEASE
      this_amount += element.days_rented * 3
    when Movie::CHILDRENS
      this_amount += 1.5
      this_amount += (element.days_rented - 3) * 1.5 if element.days_rented > 3
    end

    # add frequent renter points
    frequent_renter_points += 1
    # add bonus for a two day new release rental
    if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1
      frequent_renter_points += 1
    end
    # show figures for this rental
    result += "\t" + element.movie.title + "\t" + this_amount.to_s + "\n"
    total_amount += this_amount
  end

  result += "Amount owed id #{total_amount}\n"
  result += "You earend #{frequent_renter_points} frequent renter points"
  result
end

def statement
  total_amount = 0
  frequent_renter_points = 0
  result = "Rental Record for #{name}\n"
  @rentals.eeach do |element|
    # deeteerminee amounts for each line
    # 重构后
    this_amount = amount_for(element)

    # add frequent renter points
    frequent_renter_points += 1
    # add bonus for a two day new release rental
    if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1
      frequent_renter_points += 1
    end
    # show figures for this rental
    result += "\t" + element.movie.title + "\t" + this_amount.to_s + "\n"
    total_amount += this_amount
  end

  result += "Amount owed id #{total_amount}\n"
  result += "You earend #{frequent_renter_points} frequent renter points"
  result
end

def amount_for(rental)
  this_amount = 0
  # 将该方法 移动到rental类
  case rental.movie.price_code
  when Movie::REGULAR
    this_amount += 2
    this_amount += (rental.days_rented - 2) * 1.5 if rental.days_rented > 2
  when Movie::NEW_RELEASE
    this_amount += rental.days_rented * 3
  when Movie::CHILDRENS
    this_amount += 1.5
    this_amount += (rental.days_rented - 3) * 1.5 if rental.days_rented > 3
  end
end
