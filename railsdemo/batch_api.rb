class BatchRequests
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/batch"
      request = Rack::Request.new(env.deep_dup)
      responses = JSON.parse(request[:requests]).map do |override|
        process_request(env.deep_dup, override)
      end
      [200, {"Content-Type" => "application/json"}, [{responses: responses}.to_json]]
    else
      @app.call(env)
    end
  end

  def process_request(env, override)
    path, query = override["url"].split("?")
    env["REQUEST_METHOD"] = override["method"]
    env["PATH_INFO"] = path
    env["QUERY_STRING"] = query
    env["rack.input"] = StringIO.new(override["body"].to_s)
    status, headers, body = @app.call(env)
    body.close if body.respond_to? :close
    {status: status, headers: headers, body: body.join}
  end
end
