require "chingu"
include Gosu

require "texplay"

$LOAD_PATH << "lib"


class Game < Chingu::Window
  def initialize
    super 800, 600, false

    self.input = {
      [:escape] => :exit,
    }

    @honeycomb = Honeycomb.new
    center_cell = @honeycomb.cells[8][8]
    @player = Player.create(x: center_cell.x, y: center_cell.y + Cell::HEIGHT / 2)
  end

  def update
    super

    if button_down?(KbLeft) and button_down?(KbUp)
      if not @already_pressed
        @player.move_up_left
        @already_pressed = true
      end
    elsif button_down?(KbRight) and button_down?(KbUp)
      if not @already_pressed
        @player.move_up_right
        @already_pressed = true
      end
    elsif button_down?(KbLeft) and button_down?(KbDown)
      if not @already_pressed
        @player.move_down_left
        @already_pressed = true
      end
    elsif button_down?(KbRight) and button_down?(KbDown)
      if not @already_pressed
        @player.move_down_right
        @already_pressed = true
      end
    elsif button_down?(KbLeft)
      if not @already_pressed
        @player.move_left
        @already_pressed = true
      end
    elsif button_down?(KbRight)
      if not @already_pressed
        @player.move_right
        @already_pressed = true
      end
    else
      @already_pressed = false
    end
  end
end

class Honeycomb
  attr_reader :cells

  def initialize
    cell_image = create_cell_image

    @cells = (0 .. 32).map do |i|
      (0 .. 32).map do |j|
        Cell.create(x: i * Cell::WIDTH + (j % 2 == 0 ? Cell::WIDTH / 2 : 0),
                    y: j * Cell::HEIGHT / 4 * 3,
                    image: cell_image)
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
      ], close: true, thickness: 1, color: Cell::COLOR
    end
    image
  end
end

class Cell < Chingu::GameObject
  WIDTH, HEIGHT = [48, 48]
  COLOR = Color::WHITE
end

class Player < Chingu::GameObject
  WIDTH, HEIGHT = [16, 16]

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

  def move_left
    @x -= Cell::WIDTH
  end

  def move_right
    @x += Cell::WIDTH
  end

  def move_up_left
    @x -= Cell::WIDTH / 2
    @y -= Cell::HEIGHT / 4 * 3
  end

  def move_up_right
    @x += Cell::WIDTH / 2
    @y -= Cell::HEIGHT / 4 * 3
  end

  def move_down_left
    @x -= Cell::WIDTH / 2
    @y += Cell::HEIGHT / 4 * 3
  end

  def move_down_right
    @x += Cell::WIDTH / 2
    @y += Cell::HEIGHT / 4 * 3
  end
end


if __FILE__ == $0
  Game.new.show
end
