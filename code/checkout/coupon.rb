require 'active_support/concern'
module HasDiscountFormula
  extend ActiveSupport::Concern

  module ClassMethods
    def has_discount_formula(rule_field, accessor = :discount_formula)
      class_eval <<-RUBY
        def #{accessor}
          @#{accessor} = DiscountFormula.new(self.#{rule_field})
        end
      RUBY
    end
  end

  class DiscountFormula
    attr_reader :type, :percentage, :price

    # @rule:
    # {
    #     "discount_type" => "fixed", "pay", "percentage"
    #     "percentage" => 0.1,
    #     "price" => 10
    # }
    # pay: 固定结账
    # fixed: 折扣金额
    # percentage: 折扣比例
    def initialize(options = {})
      @type = options.fetch(:discount_type)
      @percentage = options.fetch(:percentage)
      @price = options.fetch(:price)
    end

    # 返回优惠的金额
    def diff(target_price)
      case type
      when 'pay'
        ans = target_price - price
        [ans, 0].max
      when 'fixed'
        [price, target_price].min
      when 'percentage'
        target_price * percentage
      end
    end
  end
end

class Coupon
  include HasDiscountFormula
  has_discount_formula :discount_parameters

  attr_reader :discount_type, :percentage, :price, :rules

  def initialize(options = {})
    @discount_type = options.fetch(:discount_type)
    @percentage = options.fetch(:percentage, nil)
    @price = options.fetch(:price, nil)
    @rules = options.fetch(:rules).map { |condition, quantity| Rule.new(condition, quantity) }
  end

  def discount_parameters
    {
      discount_type: discount_type,
      percentage: percentage,
      price: price
    }
  end
end

class Rule
  attr_reader :condition, :quantity
  # @condition:
  # A: Order should meet requirement A
  # B: Order should meet requirement B
  # C: Order should meet requirement C
  def initialize(condition, quantity)
    @condition = condition
    @quantity = quantity
  end

  def strategy
    @strategy ||= load_strategy
  end

  def conformed?(serial_units)
    strategy.conformed?(serial_units)
  end

  private

  def load_strategy
    case condition
    when 'A'
      A.new(quantity)
    when 'B'
      B.new(quantity)
    when 'C'
      C.new(quantity)
    end
  end

  module RuleStrategy
    attr_reader :quantity

    def conformed?(serial_units)
      serial_units.count { |unit| judgement?(unit) } >= quantity
    end

    def judgement?(_unit)
      fail 'NotImplementedError'
    end
  end

  class A
    include RuleStrategy

    def initialize(quantity)
      @quantity = quantity
    end

    # 只是一种假设 他代表需要满足的条件
    def judgement?(unit)
      unit.name == 'A'
    end
  end

  class B
    include RuleStrategy

    def initialize(quantity)
      @quantity = quantity
    end

    def judgement?(unit)
      unit.name == 'B'
    end
  end

  class C
    include RuleStrategy

    def initialize(quantity)
      @quantity = quantity
    end

    def judgement?(unit)
      unit.name == 'C'
    end
  end
end
