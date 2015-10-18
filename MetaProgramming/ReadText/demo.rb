class DataWrapper
  def self.wrap(file_name)
    data = File.new(file_name)
    header = data.gets.chomp
    data.close

    class_name = File.basename(file_name, '.txt').capitalize
    klass = Object.const_set(class_name, Class.new)

    # get attribute names
    names = header.split(',')

    # 操作类  通过class_eval define_method形成扁平作用域
    klass.class_eval do
      attr_accessor *names

      define_method(:initialize) do |*values|
        names.each_with_index do |name, i|
          instance_variable_set('@' + name, values[i])
        end
      end

      define_method(:to_s) do
        str = "<#{self.class}:"
        names.each { |name| str << " #{name}=#{send(name)}" }
        str + '>'
      end
    end

    def klass.read
      array = []
      data = File.new(to_s.downcase + '.txt')
      data.gets # throw away header
      data.each do |line|
        line.chomp!
        values = eval("[#{line}]")
        array << new(*values)
      end
      data.close
      array
    end
    klass # we return the class name
  end
end

klass = DataWrapper.wrap('location.txt')
list = klass.read
list.each do |location|
  puts("#{location.name} is from the #{location.country}")
end
