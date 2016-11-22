class ShortUrl
  attr_accessor :slug, :target, :action

  # action [:render, :redirect].sample
end

# url = Short::Url.new
# url.slug = "fowler"
# url.target = "/authors/MartinFowler"
# url.save!

class ShortDispatcher
  def initialize(router)
    @router = router
  end

  def call(env)
    id = env['action_dispatch.request.path_parameters'][:id]
    slug = ShortUrl.find_by(slug: id)
    strategy(slug).call(@router, env)
  end

  private

  def strategy(url)
    { redirect: Redirect, render: Render }.fetch(url.action).new(url)
  end

  class Redirect
    def initialize(url)
      @url = url
    end

    def call(router, env)
      to = @url.target
      router.redirect { |_p, _req| to }.call(env)
    end
  end

  class Render
    def initialize(url)
      @url = url
    end

    def call(_router, env)
      routing = Rails.application.routes.recognize_path(@url.target)
      controller = (routing.delete(:controller) + '_controller')
                   .classify
                   .constantize
      action = routing.delete(:action)
      env['action_dispatch.request.path_parameters'] = routing
      controller.action(action).call(env)
    end
  end
end

match '/:id', to: ShortDispatcher.new(self)
