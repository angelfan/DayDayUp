# ruby template
# handler = ->(template) { template.source }
ActionView::Template.register_template_handler(:rb, :source.to_proc)

# md template
# <%= ruby code %>
class MarkdownTemplateHandler
  def self.call(template)
    erb = ActionView::Template.registered_template_handler(:erb)
    source = erb.call(template)
    <<-SOURCE
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    Redcarpet::Markdown.new(renderer, options).render(begin;#{source};end)
    SOURCE


    # renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    # options = {
    #     autolink: true,
    #     no_intra_emphasis: true,
    #     fenced_code_blocks: true,
    #     lax_html_blocks: true,
    #     strikethrough: true,
    #     superscript: true
    # }
    # Redcarpet::Markdown.new(renderer, options).render(source.source).inspect
  end
end

ActionView::Template.register_template_handler(:md, MarkdownTemplateHandler)
ActionView::Template.register_template_handler(:markdown, MarkdownTemplateHandler)