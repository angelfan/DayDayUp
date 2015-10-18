# 思路： 将文件名看成类， 将列明看做属性， 那么数据就和属性建立起了关系

class DataWrapper
  def self.wrap(file_name)
    # 将文件名设置成类
    class_name = File.basename(file_name, '.txt').capitalize
    klass = Object.const_set(class_name, Class.new)

    # 将文件的第一行设置成属性
    data = File.new(file_name)
    header = data.gets.chomp
    data.close
    names = header.split(',')

    # 通过class_eval define_method消除作用域门 是Klass可以访问属性： names
    klass.class_eval do
      attr_accessor *names

      define_method(:initialize) do |*values|
        names.each_with_index do |name, i|
          instance_variable_set('@' + name, values[i])
        end
      end
    end

    class << klass
      def read
        array = []
        data = File.new(to_s.downcase + '.txt')
        data.gets
        data.each do |line|
          line.chomp!
          values = eval("[#{line}]")
          array << new(*values)
        end
        data.close
        array
      end

      def find_by_id(id)
        array = read
        result = []
        array.each do |user|
          result << user if user.id == id
        end
        result
      end
    end

    klass # we return the class name
  end
end

users = DataWrapper.wrap('user.txt').find_by_id(1)
p users[0].name
