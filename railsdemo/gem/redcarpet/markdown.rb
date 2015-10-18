require 'redcarpet'
require 'coderay'
def markdown(text)
  options = {
    autolink: true,
    space_after_headers: true,
    fenced_code_blocks: true,
    no_intra_emphasis: true,
    hard_wrap: true,
    strikethrough: true
  }
  markdown = Redcarpet::Markdown.new(HTMLwithCodeRay, options)
  markdown.render(h(text)).html_safe
end

class HTMLwithCodeRay < Redcarpet::Render::HTML
  def block_code(code, language)
    CodeRay.scan(code, language).div(tab_width: 2)
  end
end

#
# class HTMLwithPygments < Redcarpet::Render::HTML
#   def block_code(code, language)
#     Pygments.highlight(code, lexer: language)
#   end
# end
#
# def markdown(text)
#   renderer = Redcarpet::Render::HTML.new(hard_wrap: true, filter_html: true)
#   # renderer = HTMLwithPygments.new(hard_wrap: true, filter_html: true)
#   options = {
#       autolink: true,
#       no_intra_emphasis: true,
#       fenced_code_blocks: true,
#       lax_html_blocks: true,
#       strikethrough: true,
#       superscript: true
#   }
#   Redcarpet::Markdown.new(renderer, options).render(text).html_safe
# end
