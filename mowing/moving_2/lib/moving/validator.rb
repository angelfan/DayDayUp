module Moving
  module Validator
    def validator_direction(direction)
      fail '方向设置不在: N W S W 中' unless %w(N W S E).include?(direction)
    end
  end
end