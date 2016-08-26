require 'active_support/core_ext/string/inflections'

class Request
  # 这些基本的东西rack/request已经封装好了 可以直接拿来用
  # 不过我们自己简单写一下好了
  # include Rack::Request::Helpers
  # include Rack::Request::Env

  attr_reader :env, :params

  def initialize(env)
    @env = env
    @params = get_params
  end

  def get_header(name)
    env[name]
  end

  def set_header(name, value)
    env[name] = value
  end

  def path_info
    get_header('PATH_INFO')
  end

  def query_string
    get_header('QUERY_STRING')
  end

  def get_params
    query_string.split('&').each_with_object({}) do |v, params|
      param, value = v.split('=')
      params[param] = value
    end
  end

  def request_method
    get_header('REQUEST_METHOD')
  end

  # {'action' => 'my_action', 'controller' => 'my_controller'}
  def path_parameters
    get_header('path_parameters') || {}
  end

  def path_parameters=(path_parameters)
    set_header('path_parameters', path_parameters)
  end

  def controller_class
    params = path_parameters

    if params.key?(:controller)
      controller_param = params[:controller].underscore
      const_name = "#{controller_param.camelize}Controller"
      Object.const_get(const_name)
    else
      NotFoundError
    end
  rescue NameError => _e
    NotFoundError
  end

  class NotFoundError
    def self.dispatch(_method, _req)
      new.call
    end

    def call
      [404, { 'X-Cascade' => 'pass' }, ['not found']]
    end
  end
end
