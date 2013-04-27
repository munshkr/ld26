require "chingu"
include Gosu

$LOAD_PATH << "lib"
require "minimal_game_object"


class Game < Chingu::Window
  def initialize
    super

    self.input = {
      [:escape] => :exit,
    }

    @cell = Cell.create(x: $window.width / 2, y: $window.height / 2)
  end
end

class Cell < MinimalGameObject
  def setup
    @line_color = Color::WHITE
    @width, @height = [32, 32]
  end

  def render
    # draw_quad?
  end

  def update
    @angle += 5
  end
end


if __FILE__ == $0
  Game.new.show
end
