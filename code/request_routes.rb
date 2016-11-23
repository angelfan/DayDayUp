class ApiRequest
  attr_accessor :id, :request_method, :request_path
end

require 'erb'

class JsonTemplateHandler
  include ERB::Util

  def initialize(template, params)
    @template = template
    define_param_methods(params)
  end

  # Expose private binding() method.
  def get_binding
    binding()
  end

  def render
    renderer.result(binding)
  end

  private

  def renderer
    ERB.new(@template)
  end

  def define_param_methods(params)
    params.each do |k, v|
      self.class.send(:define_method, k) { return v }
    end
  end

  def method_missing(method_name, *_args, &_block)
    method_name.to_s
  end
end

template = {
    "id": "<%= id %>"
}.to_s
JsonTemplateHandler.new(template, {id: 10}).render

class ParamsGuard
  def initialize(params)
    @params = params_white_list(params)
  end

  def filtered_params
    replace_file_with_attachment_url
    @params
  end

  private

  def params_white_list(params)
    params.except(:defaults, :controller, :action, :format)
  end

  def replace_file_with_attachment_url
    @params.each do |param|
      if @params[param].is_a?(ActionDispatch::Http::UploadedFile)
        attachment = Attachment.create!(file: @params[param])
        @params[param] = attachment.file.url
      end
    end
  end
end


# config/initializers/request_routes.rb
class RequestRoutes
  include Singleton

  def match(path, method)
    memos = simulate.simulate(path).try(:memos)
    return nil if memos.blank?
    memos.reverse.find { |memo| memo[:request_method] == method }
  end

  def add_route(api_request)
    append_to_ast(api_request)
    clear_cache
  end

  def clear_cache
    @simulate = nil
  end

  def reload
    @ast = nil
    @simulate = nil
  end

  private

  def simulate
    @simulate ||= begin
      builder = ActionDispatch::Journey::GTG::Builder.new ActionDispatch::Journey::Nodes::Or.new ast
      table = builder.transition_table
      ActionDispatch::Journey::GTG::Simulator.new table
    end
  end

  def ast
    @ast ||= begin
      ApiRequest.all.map do |api_request|
        parse_to_nodes(api_request)
      end
    end
  end

  def parse_to_nodes(api_request)
    memo = {
        request_id: api_request.id,
        request_method: api_request.request_method,
        pattern: ActionDispatch::Journey::Path::Pattern.from_string(api_request.request_path)
    }
    nodes = parser.parse api_request_full_path(api_request)
    nodes.each { |n| n.memo = memo }
    nodes
  end

  def append_to_ast(api_request)
    @ast = ast || []
    @ast << parse_to_nodes(api_request)
  end

  def api_request_full_path(api_request)
    "/#{api_request.project.slug}#{api_request.request_path}"
  end

  def parser
    ActionDispatch::Journey::Parser.new
  end
end

# route
MockServer::Application.routes.draw do
  Project.all.each do |project|
    match "#{project.slug}/*path", to: 'request_handler#handle', via: :all, defaults: { format: :json }
  end
end

# controller
class RequestHandlerController < ApplicationController
  include ErrorHandling

  before_action :set_default_format, :find_request

  def handle
    if @request.present?
      merge_params_from_path
      check_required_headers(@request)
      check_required_params(@request)
      render json: JsonTemplateHandler.new(@request.return_json, filtered_params).render, status: @request.status_code.to_sym
    else
      fail ApplicationError, 'api not exist!'
    end
  end

  private

  def find_request
    @memo = RequestRoutes.instance.match(request.path, request.method)
    if @memo.present?
      @request = ApiRequest.find_by(id: @memo[:request_id])
    else
      fail ApplicationError
    end
  end

  def merge_params_from_path
    match_date = @memo[:pattern].match("/#{params[:path]}")
    match_date.names.zip(match_date.captures).to_h.each do |k, v|
      params[k] = v
    end
  end

  def filtered_params
    clone_params = params.clone
    ParamsGuard.new(clone_params).filtered_params
  end

  def set_default_format
    request.format = :json
  end

  def check_required_params(api_request)
    required = api_request.parameters.required.pluck(:name)
    params.required(required)
  rescue ActionController::ParameterMissing => exception
    raise MissingParamError, caused_by: exception.param
  end

  def check_required_headers(api_request)
    api_request.headers.each do |header|
      unless request.headers[header.key].present? && request.headers[header.key] == header.value
        fail MissingHeaderError, caused_by: header.key
      end
    end
  end
end
