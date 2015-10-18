require 'yaml'

module ConfigParser
  class << self
    def add_attribute(klass, symbol)
      codes = %{
        def #{symbol}
          return @#{symbol}
        end

        def #{symbol}=(value)
          @#{symbol} = value
        end
      }

      klass.instance_eval(codes)
    end

    # 接受读取的yml文件，可以理解成接收hash数据
    def expand_configs(configs = {})
      configs.each do |key, value|
        expand_sub_configs(key, value)
      end
    end

    def expand_sub_configs(prefix, configs)
      if configs.class != Hash
        add_attribute(Configs, prefix)
        eval("Configs.#{prefix} = configs")
      else
        configs.each do |key, value|
          expand_sub_configs(prefix + '_' + key, value)
        end
      end
    end
  end
end

# if ARGV.size != 1
#   puts "Usage: ..."
#   exit(-1)
# end

Configs = Class.new
# ConfigParser.expand_configs(YAML.load(File.open(ARGV[0])))
ConfigParser.expand_configs(YAML.load(File.open('config.yml')))
puts 'Storage information:'
puts " #{Configs.Storage_IP}"
puts "  #{Configs.Storage_Port}"
puts "  #{Configs.Storage_SSL_Port}"
puts "  #{Configs.Storage_Service_Port}\n"

puts 'DB information: '
puts "  #{Configs.DB_IP}"
puts "  #{Configs.DB_User}"
puts "  #{Configs.DB_Password}\n"

puts 'Manifests information: '
Configs.Manifests.each do |info|
  info.each do |k, v|
    puts "  #{k}: #{v}"
  end
end
