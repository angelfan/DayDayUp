$redis.subscribe("bravo") do |on|
  on.message do |channel, message|
    Rails.logger.info("Broadcast on channel #{channel}: #{message}")
  end
end


$redis.publish 'channel', { object: 1123 }