class Player
  attr_reader :board, :name
  def initialize(name)
    @board = Board.new(name)
    @name = name
  end
end

class Board
  attr_accessor :spots, :cruiser, :battleship, :destroyer, :b_hash, :spots
  attr_reader :ship_locations, :name
  def initialize(name)
    create_spots
    @battleship = Ship.new(spots, 3)
    clear_spots(battleship.location)
    @cruiser = Ship.new(spots, 2)
    clear_spots(cruiser.location)
    @destroyer = Ship.new(spots, 1)
    @name = name
    @ship_locations = [cruiser.location, battleship.location, [destroyer.location]]
  end


  def create_spots
    @spots = (1..5).to_a.product((1..5).to_a)
    @b_hash = {}
    spots.each do |x|
      @b_hash[x] = ' '
    end
  end

  def clear_spots(blocks)
    blocks.each do |x|
      spots.delete(x)
    end
  end

  def draw_board
    puts "#{name}'s Board"
    puts ""
    puts  "  1   2   3   4   5"
    puts "  +---+---+---+---+---+"
    puts "1 | #{b_hash[[1,1]]} | #{b_hash[[2,1]]} | #{b_hash[[3,1]]} | #{b_hash[[4,1]]} | #{b_hash[[5,1]]} |"
    puts "  +---+---+---+---+---+"
    puts "2 | #{b_hash[[1,2]]} | #{b_hash[[2,2]]} | #{b_hash[[3,2]]} | #{b_hash[[4,2]]} | #{b_hash[[5,2]]} |"
    puts "  +---+---+---+---+---+"
    puts "3 | #{b_hash[[1,3]]} | #{b_hash[[2,3]]} | #{b_hash[[3,3]]} | #{b_hash[[4,3]]} | #{b_hash[[5,3]]} |"
    puts "  +---+---+---+---+---+"
    puts "4 | #{b_hash[[1,4]]} | #{b_hash[[2,4]]} | #{b_hash[[3,4]]} | #{b_hash[[4,4]]} | #{b_hash[[5,4]]} |"
    puts "  +---+---+---+---+---+"
    puts "5 | #{b_hash[[1,5]]} | #{b_hash[[2,5]]} | #{b_hash[[3,5]]} | #{b_hash[[4,5]]} | #{b_hash[[5,5]]} |"
    puts "  +---+---+---+---+---+"

    puts "#{destroyer.show_status}   #{cruiser.show_status}   #{battleship.show_status} "
    puts ""
  end

  def check_hit(loc)
    ship_locations.each do |x|
      x.each do |y|
        if loc == y
          b_hash[loc] = 'X'
          check_ship_status
          return
        end
      end
      b_hash[loc]= '/'
    end
  end

  def check_ship_status
    if b_hash[battleship.location[0]] =='X' && b_hash[battleship.location[1]] == 'X' && b_hash[battleship.location[2]] == 'X'
      battleship.status = 'Dead'
    end
    if b_hash[destroyer.location] == 'X'
      destroyer.status = 'Dead'
    end

    if b_hash[cruiser.location[0]] == 'X' && b_hash[cruiser.location[1]] == 'X'
      cruiser.status = 'Dead'
    end
  end

  def check_lost
    if cruiser.status == 'Dead' && destroyer.status == 'Dead' && battleship.status == 'Dead'
      return true
    end
    false
  end
end

class Ship
  attr_accessor :battleship, :name, :status, :spots, :space, :location

  def initialize(spots, size)
    @spots = spots
    @space = spots.sample
    make_ship(size)
    @status = 'Alive'
  end

  def make_ship(size)
    case size
      when 3
        @name = 'Battleship'
        @location = place_battleship(spots)
      when 2
        @name = 'Cruiser'
        @location = place_destroyer(spots)
      when 1
        @name = 'Destroyer'
        @location = spots.sample
    end
  end

  def place_battleship(spots)
    possibles = []
    if spots.include?([space[0],space[1]+1]) && spots.include?([space[0],space[1]]) && spots.include?([space[0],space[1]-1])
      possibles<< [[space[0],space[1]+1],[space[0],space[1]],[space[0],space[1]-1]]
    end

    if spots.include?([space[0],space[1]]) && spots.include?([space[0],space[1]+1]) && spots.include?([space[0],space[1]+2])
      possibles<< [[space[0],space[1]],[space[0],space[1]+1],[space[0],space[1]+2]]
    end

    if spots.include?([space[0],space[1]-2]) && spots.include?([space[0],space[1]-1]) && spots.include?([space[0],space[1]])
      possibles<< [[space[0],space[1]-2],[space[0],space[1]-1],[space[0],space[1]]]
    end

    if spots.include?([space[0]+1,space[1]]) && spots.include?([space[0],space[1]]) && spots.include?([space[0]-1,space[1]])
      possibles<< [[space[0]+1,space[1]],[space[0],space[1]],[space[0]-1,space[1]]]
    end

    if spots.include?([space[0],space[1]]) && spots.include?([space[0]+1,space[1]]) && spots.include?([space[0]+2,space[1]])
      possibles<< [[space[0],space[1]],[space[0]+1,space[1]],[space[0]+2,space[1]]]
    end

    if spots.include?([space[0]-2,space[1]]) && spots.include?([space[0]-1,space[1]]) && spots.include?([space[0],space[1]])
      possibles<< [[space[0]-2,space[1]],[space[0]-1,space[1]],[space[0],space[1]]]
    end
    possibles.sample
  end

  def place_destroyer(spots)
    possibles = []

    if spots.include?([space[0],space[1]+1]) && spots.include?([space[0],space[1]])
      possibles<< [[space[0],space[1]+1],[space[0],space[1]]]
    end

    if spots.include?([space[0],space[1]-1]) && spots.include?([space[0],space[1]])
      possibles<< [[space[0],space[1]-1],[space[0],space[1]]]
    end

    if spots.include?([space[0]+1,space[1]]) && spots.include?([space[0],space[1]])
      possibles<< [[space[0]+1,space[1]],[space[0],space[1]]]
    end

    if spots.include?([space[0]-1,space[1]+1]) && spots.include?([space[0],space[1]])
      possibles<< [[space[0]-1,space[1]],[space[0],space[1]]]
    end
    possibles.sample
  end

  def show_status
    "#{name}: #{status}"
  end
end

class Game
  attr_reader :player, :computer, :computer_play
  attr_accessor :current_player

  def initialize
    @player = Player.new('Johnny Arcade')
    @computer = Player.new('R2D2')
    @computer_play = (1..5).to_a.product((1..5).to_a)
    @current_player = player
  end

  def show_boards
    system 'clear'
    player.board.draw_board
    computer.board.draw_board
  end

  def player_moves(c_board)
    move = []
    puts "Please select a square (such as 3, 5) to open fire!"
    loop do
      selection = gets.chomp
      if selection[0].to_i == 0  || selection[1] != ',' || selection[2] != ' ' || selection[3] .to_i == 0 || selection.size > 4
        puts 'INVALID FORMAT, TRY AGAIN'
      elsif selection[0].to_i > 5 || selection[0].to_i < 1 || selection[3].to_i > 5 || selection[3].to_i < 1
        puts "OUT OF RANGE, TRY AGAIN"
      elsif c_board.b_hash[[selection[0].to_i, selection[3].to_i]] != ' '
        puts 'NOT AN EMPTY SQUARE, TRY AGAIN'
      else
        c_board.check_hit([selection[0].to_i, selection[3].to_i])
        break
      end
    end
  end


  def computer_moves(p_board)
    move = computer_play.delete(computer_play.sample)
    p_board.check_hit(move)
  end

  def someone_won?(p_board, c_board)
    if c_board.check_lost
      puts "Congratulations #{player.name} has won game!"
      return true
    elsif p_board.check_lost
      puts "#{computer.name} has won the game!"
      return true
    else
      return false
    end
  end

  def play
    show_boards
    loop do
      player_moves(computer.board)
      show_boards
      computer_moves(player.board)
      show_boards
      break if someone_won?(player.board, computer.board)
    end
  end
end

game = Game.new
game.play