class Route # :nodoc:
  class Matcher
    # 'hello/:id/' 要可以识别 '/hello/test' 的path_info
    # 'hello/test' 要可以识别 '/hello/test.js' 的path_info
    attr_reader :path_regexp, :method_regexp

    def initialize(path, method)
      @path = path
      @method_regexp = /^#{method.upcase}$/
      @path_regexp = path_to_regexp # 一开始就准备好, 之后就不用每次都去重新生成一次了
    end

    def params
      params = @path.split('/').select { |v| v =~ /^:/ } << ':format'
      params.map { |p| p.delete(':') }
    end

    def match?(path_info, method)
      @method_regexp.match(method) && @path_regexp.match(path_info)
    end

    def match_data(path_info)
      match = @path_regexp.match(path_info)
      return unless match
      MatchData.new(params, match)
    end

    private

    # 'hello/test => /\A\/hello\/test(?:\.([^\/.?]+))?\Z/
    # 'hello/:id  => /\A\/hello\/([^\/.?]+)(?:\.([^\/.?]+))?\Z/
    def path_to_regexp
      reg_str = @path.split('/').map do |v|
        if v =~ /^:/
          '\/([^\/.?]+)'
        else
          '\/' + v
        end
      end.join

      %r{\A#{reg_str}(?:\.([^\/.?]+))?\Z}
    end
  end

  class MatchData # :nodoc:
    attr_reader :names

    def initialize(names, match)
      @names   = names
      @match   = match
    end

    def captures
      result = {}
      names.each_with_index do |name, index|
        result[name] = @match[index + 1]
      end
      result
    end
  end

  attr_reader :path, :to

  def initialize(path, method, to)
    @path = build_path(path, method)
    @to = to
  end

  def path_parameters
    controller, action = to.split('#')
    { controller: controller, action: action }
  end

  private

  def build_path(path, method)
    Matcher.new(path, method)
  end
end

# matcher = Route::Matcher.new('hello/:test', 'get')
#
# matcher.match?('/hello/123', 'GET')
# matcher.match_data('/hello/123').captures
