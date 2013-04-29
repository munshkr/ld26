require "chingu"
include Gosu

require "texplay"

$LOAD_PATH << "lib"
require "states"
require "game_objects"


SCREEN_WIDTH, SCREEN_HEIGHT      = [800, 600]
SCREEN_CENTER_X, SCREEN_CENTER_Y = [SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2]


class Game < Chingu::Window
  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT, false

    self.input = {
      escape: :exit,
    }

    switch_game_state(Play)
    #transitional_game_state(Chingu::GameStates::FadeTo, speed: 10)
  end
end


if __FILE__ == $0
  Game.new.show
end
