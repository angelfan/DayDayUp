module CanCan
  module Ability
    # 匹配到相应的rule, 返回bool
    def can?(action, subject, *extra_args)
      match = relevant_rules_for_match(action, subject).detect do |rule|
        rule.matches_conditions?(action, subject, extra_args)
      end
      match ? match.base_behavior : false
    end
  end
end
