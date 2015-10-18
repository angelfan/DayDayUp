module ApplicationHelper
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
end

class BasePresenter < SimpleDelegator
  def initialize(model, view)
    @model = model
    @view = view
    super(@model)
  end

  private

  def self.presents(name)
    define_method(name) do
      @model
    end
  end

  def h
    @view
  end
end

class PostPresenter < BasePresenter
  presents :user

  def publication_status
    if @model.published_at?
      h.time_ago_in_words(@model.published_at)
    else
      'Draft'
    end
  end
end
