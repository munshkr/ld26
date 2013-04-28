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
    @camera_x = 0
    @camera_y = 0

    every(1000, name: :move) do
      #advance
    end

    self.input = {
      holding_up: :advance,
      holding_down: :retreat,
      holding_left: :rotate_left,
      holding_right: :rotate_right,
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
      $window.translate(-@camera_x, -@camera_y) do
        $window.rotate(@camera_angle, @camera_x, @camera_y) do
          @honeycomb.draw
        end
      end

      super
    end
  end

  def advance
    dist = Cell::RADIUS * Math.sqrt(3)
    @camera_x += offset_x(90 - @camera_angle, dist)
    @camera_y += offset_y(90 - @camera_angle, dist)

    @player.advance
  end

  def retreat
    dist = Cell::RADIUS * Math.sqrt(3)
    @camera_x -= offset_x(90 - @camera_angle, dist)
    @camera_y -= offset_y(90 - @camera_angle, dist)
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
