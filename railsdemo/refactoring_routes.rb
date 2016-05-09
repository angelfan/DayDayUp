class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

YourApplication::Application.routes.draw do
  # def draw(routes_name)
  #   instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  # end

  # Loads config/routes/common.rb
  draw :common
  # Loads config/routes/another.rb
  draw :another
end