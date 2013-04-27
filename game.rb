require "chingu"
include Gosu

require "texplay"

$LOAD_PATH << "lib"


class Game < Chingu::Window
  def initialize
    super 800, 600, false

    push_game_state(Play)

    self.input = {
      escape: :exit,
    }
  end
end

class Play < Chingu::GameState
  trait :timer

  def initialize
    super

    @honeycomb = Honeycomb.new
    @player = Player.create(x: $window.width / 2, y: $window.height / 2, angle: 180)

    every(500, name: :move) do
      advance
    end

    self.input = {
      left: :rotate_left,
      right: :rotate_right,
    }
  end

  def update
    super

    $window.caption = "FPS #{$window.fps} - " \
      "milliseconds_since_last_tick: #{$window.milliseconds_since_last_tick} - " \
      "game objects #{current_game_state.game_objects.size}"
  end

  def draw
    @honeycomb.draw
    super
  end

  def advance
    # TODO
  end

  def rotate_left
    # TODO
  end

  def rotate_right
    # TODO
  end
end

class Honeycomb < Chingu::GameObjectList
  attr_reader :cells

  def initialize(options={})
    super

    cell_image = create_cell_image

    @cells = (-32 .. 32).map do |i|
      (-32 .. 32).map do |j|
        x = (i * Cell::WIDTH + (j % 2 == 0 ? Cell::WIDTH / 2 : 0))
        y = j * Cell::HEIGHT / 4 * 3

        cell = Cell.new(x: x, y: y,
                        center_x: x + Cell::WIDTH / 2, center_y: y + Cell::HEIGHT / 2,
                        image: cell_image)

        add_game_object(cell)
      end
    end
  end

  def create_cell_image
    image = TexPlay.create_blank_image($window, Cell::WIDTH * 3, Cell::HEIGHT * 3)
    image.paint do
      polyline [
        Cell::WIDTH / 2, 0,
        Cell::WIDTH, Cell::HEIGHT / 4,
        Cell::WIDTH, Cell::HEIGHT / 4 * 3,
        Cell::WIDTH / 2, Cell::HEIGHT,
        0, Cell::HEIGHT / 4 * 3,
        0, Cell::HEIGHT / 4,
      ], close: true, thickness: 2, color: Cell::COLOR
    end
    image
  end
end

class Cell < Chingu::GameObject
  WIDTH, HEIGHT = [48, 48]
  COLOR = Color::WHITE
  COLOR.alpha = 80

  def center_x
    @x + WIDTH / 2
  end

  def center_y
    @y + HEIGHT / 2
  end
end

class Player < Chingu::GameObject
  WIDTH, HEIGHT = [16, 16]
  VELOCITY_INC = 0.5

  def initialize(*args)
    super

    @color = options[:color] || Color::BLUE

    @image = TexPlay.create_blank_image($window, WIDTH + 2, HEIGHT + 3)
    @image.paint do
      polyline [
        WIDTH, 0,
        0, HEIGHT / 2,
        WIDTH, HEIGHT
      ], close: true, thickness: 2, color: @color
    end
  end

  def update
    case @movement_direction
    when :left
      @velocity_x ||= 0
      if @x < @original_x - Cell::WIDTH
        @velocity_x = 0
        #@x = @original_x - Cell::WIDTH
        @movement_direction = nil
      elsif @x < @original_x - Cell::WIDTH / 2
        @velocity_x -= VELOCITY_INC
      else
        @velocity_x += VELOCITY_INC
      end
      @x -= @velocity_x
    else
      @original_x = @x
    end
  end

  def moving?
    !!@movement_direction
  end

  def still?
    not moving?
  end

  def move_left
    @movement_direction = :left
  end

  def move_right
    #@x += Cell::WIDTH
    @movement_direction = :right
  end

  def move_up_left
    #@x -= Cell::WIDTH / 2
    #@y -= Cell::HEIGHT / 4 * 3
  end

  def move_up_right
    #@x += Cell::WIDTH / 2
    #@y -= Cell::HEIGHT / 4 * 3
  end

  def move_down_left
    #@x -= Cell::WIDTH / 2
    #@y += Cell::HEIGHT / 4 * 3
  end

  def move_down_right
    #@x += Cell::WIDTH / 2
    #@y += Cell::HEIGHT / 4 * 3
  end
end


if __FILE__ == $0
  Game.new.show
end
