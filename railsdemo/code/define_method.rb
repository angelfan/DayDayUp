class Game
  attr_accessor :name, :year, :system

  def runs_on_snes?
    system == 'SNES'
  end

  def runs_on_ps1?
    system == 'PS1'
  end

  def runs_on_genesis?
    system == 'Genesis'
  end
end

class Game
  attr_accessor :name, :year, :system

  %w(SNES PS1 Genesis).each do |name|
    define_method "runs_on_#{name.downcase}?" do
      self.system = name
    end
  end
end

class Library
  SYSTEMS = %w(arcade atari pc)

  attr_accessor :games

  def method_missing(name, *args)
    system = name.to_s
    if SYSTEMS.include?(system)
      self.class.class_eval do
        define_method(system) do
          find_by_system(system)
        end
      end
      send(system)
    else
      super
    end
  end

  private

  def find_by_system(system)
    games.select { |game| game.system == system }
  end
end
