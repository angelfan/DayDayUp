class ForbidFirefox
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['HTTP_USER_AGENT'].downcase.include?('firefox')
      [400, { 'Content-Type' => 'text/plain' }, ['400 error, you are using firefox!']]
    else
      @app.call(env)
    end
  end
end

class TestForbidFirefox
  def initialize
    super
  end

  def call(_env)
    [200, { 'Content-Type' => 'text/plain' }, ['worked, you are not firefox']]
  end
end

use ForbidFirefox
run TestForbidFirefox.new

# rackup