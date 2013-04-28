require "game_objects"
require "util"

include Util

class Play < Chingu::GameState
  trait :timer

  ANGLE_STEP = 60
  DURATION_ROTATION = 250
  DURATION_ADVANCE  = 250

  def initialize
    super

    @honeycomb = Honeycomb.new
    @player = Player.create(x: 0, y: 0,
                            current_cell: @honeycomb.cells.first)

    @camera_angle = 30
    @camera_x = 0
    @camera_y = 0

    every(1000, name: :move) do
      advance
    end

    self.input = {
      holding_up: :advance,
      holding_left: :rotate_left,
      holding_right: :rotate_right,
    }
  end

  def update
    super

    # animations
    if rotating?
      t = Gosu::milliseconds - @rotation_old_time
      if t > DURATION_ROTATION
        @camera_angle = @rotation_old_camera_angle + @rotation_change
        @rotation_change = nil
        @player.rotate_right
      else
        b = @rotation_old_camera_angle
        c = @rotation_change
        @camera_angle = ease_in_out_quad(t, b, c, DURATION_ROTATION)
      end
    end

    if advancing?
      t = Gosu::milliseconds - @advance_old_time
      if t > DURATION_ADVANCE
        @camera_x = @advance_old_camera_x + @advance_change_x
        @camera_y = @advance_old_camera_y + @advance_change_y
        @advance_change_x = @advance_change_y = nil
        @player.advance
        @honeycomb.move(@camera_x, @camera_y)
      else
        b = @advance_old_camera_x
        c = @advance_change_x
        @camera_x = ease_in_out_quad(t, b, c, DURATION_ADVANCE)
        b = @advance_old_camera_y
        c = @advance_change_y
        @camera_y = ease_in_out_quad(t, b, c, DURATION_ADVANCE)
      end
    end

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
    if not moving?
      @advance_old_camera_x = @camera_x
      @advance_old_camera_y = @camera_y
      @advance_old_time = Gosu::milliseconds

      dist = Cell::RADIUS * Math.sqrt(3)
      @advance_change_x = offset_x(90 - @camera_angle, dist)
      @advance_change_y = offset_y(90 - @camera_angle, dist)
    end
  end

  def rotate_left
    if not moving?
      @rotation_old_camera_angle = @camera_angle
      @rotation_old_time = Gosu::milliseconds
      @rotation_change = ANGLE_STEP
    end
  end

  def rotate_right
    if not moving?
      @rotation_old_camera_angle = @camera_angle
      @rotation_old_time = Gosu::milliseconds
      @rotation_change = -ANGLE_STEP
    end
  end

  def rotating?
    !!@rotation_change
  end

  def advancing?
    !!@advance_change_x
  end

  def moving?
    rotating? or advancing?
  end
end
