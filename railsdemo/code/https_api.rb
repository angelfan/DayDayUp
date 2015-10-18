require 'net/https'
require 'uri'

def post_api(api, args)
  uri = URI.parse api
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri.request_uri)
  req.set_form_data(args)
  response = http.request(req)
  JSON.load(response.body)
end

def get_api(api, args)
  uri = URI.parse api
  uri.query = args.collect { |a| "#{a[0]}=#{URI.encode(a[1].to_s)}" }.join('&')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(req)
  JSON.load(response.body)
end
