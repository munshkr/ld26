require "game_objects"

class Play < Chingu::GameState
  trait :timer

  ANGLE_STEP = 60

  def initialize
    super

    @honeycomb = Honeycomb.new
    @player = Player.create(x: 0, y: 0,
                            current_cell: @honeycomb.first)

    @camera_angle = 30

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
    $window.translate(SCREEN_CENTER_X, SCREEN_CENTER_Y) do
      $window.rotate(@camera_angle, 0, 0) do
        @honeycomb.draw
      end
      super
    end
  end

  def advance
    @player.advance
  end

  def rotate_left
    @camera_angle += ANGLE_STEP
    @player.rotate_left
  end

  def rotate_right
    @camera_angle -= ANGLE_STEP
    @player.rotate_right
  end
end
