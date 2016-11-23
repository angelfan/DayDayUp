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
p JsonTemplateHandler.new(template, {id: 10}).render