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
    @player = Player.create(x: $window.width / 2,
                            y: $window.height / 2,
                            current_cell: @honeycomb.first)

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
    @player.advance
  end

  def rotate_left
    @player.rotate_left
  end

  def rotate_right
    @player.rotate_right
  end
end

class Honeycomb < Chingu::GameObjectList
  attr_reader :cells

  def initialize(options={})
    super

    #@cell_adjacency_list = {}

    offset_x = Cell::WIDTH / 4
    offset_y = Cell::HEIGHT / 2

    (-32 .. 32).each do |i|
      (-32 .. 32).each do |j|
        x = offset_x + (i * Cell::WIDTH + (j % 2 == 0 ? Cell::WIDTH / 2 : 0))
        y = offset_y + (j * Cell::HEIGHT / 4 * 3)

        cell = Cell.new(x: x, y: y,
                        center_x: x + Cell::WIDTH / 2,
                        center_y: y + Cell::HEIGHT / 2)

        #@cell_adjacency_list[cell]

        add_random_gates(cell)
        add_game_object(cell)
      end
    end
  end

  # NOTE temporal
  def add_random_gates(cell)
    cell.gates = []
    [:up, :down, :left, :right, :diag].each do |gate|
      cell.gates << gate if rand(6).zero?
    end
  end
end

class Cell < Chingu::GameObject
  WIDTH, HEIGHT = [64, 64]
  COLOR = Color::WHITE
  COLOR.alpha = 60

  attr_accessor :gates

  def initialize(options={})
    super(options.merge(image: self.class.cell_image))
  end

  def draw
    super

    gates.each do |gate|
      self.class.gate_image(gate).draw(self.center_x, self.y, 0)
    end
  end

  def center_x
    self.x + WIDTH / 2
  end

  def center_y
    self.y + HEIGHT / 2
  end

  def self.cell_image
    @cell_image ||= begin
      image = TexPlay.create_blank_image($window, WIDTH * 3, HEIGHT * 3)
      image.paint do
        polyline [
          WIDTH / 2, 0,
          WIDTH, HEIGHT / 4,
          WIDTH, HEIGHT / 4 * 3,
          WIDTH / 2, HEIGHT,
          0, HEIGHT / 4 * 3,
          0, HEIGHT / 4,
        ], close: true, thickness: 2, color: COLOR
      end
      image
    end
  end

  def self.gate_image(gate)
    @gate_images ||= {}
    @gate_images[gate] ||= begin
      image = TexPlay.create_blank_image($window, WIDTH * 3, HEIGHT * 3)
      image.paint do
        case gate
        when :up
          line WIDTH / 2, 0,
               WIDTH, HEIGHT / 4,
               thickness: 3, color: Color::GREEN
        when :right
          line WIDTH, HEIGHT / 4,
               WIDTH, HEIGHT / 4 * 3,
               thickness: 3, color: Color::GREEN
        when :down
          line WIDTH, HEIGHT / 4 * 3,
               WIDTH / 2, HEIGHT,
               thickness: 3, color: Color::GREEN
        when :diag
          line WIDTH / 2, HEIGHT,
               0, HEIGHT / 4 * 3,
               thickness: 3, color: Color::GREEN
        when :left
          line 0, HEIGHT / 4 * 3,
               0, HEIGHT / 4,
               thickness: 3, color: Color::GREEN
        end
      end
      image
    end
  end
end

class Player < Chingu::GameObject
  WIDTH, HEIGHT = [16, 16]
  VELOCITY_INC = 0.5

  def initialize(options={})
    super

    self.angle = 180

    @color = options[:color] || Color::BLUE

    self.image = TexPlay.create_blank_image($window, WIDTH + 2, HEIGHT + 3)
    self.image.paint do
      polyline [
        WIDTH, 0,
        0, HEIGHT / 2,
        WIDTH, HEIGHT
      ], close: true, thickness: 2, color: @color
    end
  end

  def advance
  end

  def rotate_left
  end

  def rotate_right
  end
end


if __FILE__ == $0
  Game.new.show
end
