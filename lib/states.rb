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

    self.input = {
      holding_up: :advance,
      holding_left: :rotate_left,
      holding_right: :rotate_right,
    }
  end

  def setup
    Cell.destroy_all
    Wall.destroy_all
    Player.destroy_all

    @player = Player.create(x: 0, y: 0, angle: 30)
    @honeycomb = Honeycomb.new

    every(1000, name: :move) do
      advance
    end
  end

  def update
    super

    Player.each_collision(Wall) do |p, w|
      switch_game_state(Play)
    end

    # animations
    if rotating?
      t = Gosu::milliseconds - @rotation_old_time
      if t > DURATION_ROTATION
        @player.angle = @rotation_old_player_angle + @rotation_change
        @rotation_change = nil
      else
        b = @rotation_old_player_angle
        c = @rotation_change
        @player.angle = ease_in_out_quad(t, b, c, DURATION_ROTATION)
      end
    end

    if advancing?
      t = Gosu::milliseconds - @advance_old_time
      if t > DURATION_ADVANCE
        @player.x = @advance_old_player_x + @advance_change_x
        @player.y = @advance_old_player_y + @advance_change_y
        @advance_change_x = @advance_change_y = nil
        @honeycomb.move(@player.x, @player.y)

        # Check collision on new current cell
        #dir = Honeycomb.direction_from_angle(@player.angle)
        #puts "current direction = #{dir}"
        #puts "@player.current_cell.walls = #{@player.current_cell.walls.map {|w| w.direction}}"

        #if @player.current_cell.walls.map(&:direction).include?(dir)
          #puts "COLLISION"
        #end

        # Find new current cell (the ugly way)
        #puts "player #{@player.x},#{@player.y}"
        @honeycomb.cells.each do |row|
          row.each do |cell|
            if (@player.x .. @player.x + Cell::DIAMETER).cover?(cell.x) and
               (@player.y .. @player.y + Cell::DIAMETER / 2).cover?(cell.y)
              @player.current_cell = cell
            end
          end
        end

      else
        b = @advance_old_player_x
        c = @advance_change_x
        @player.x = ease_in_out_quad(t, b, c, DURATION_ADVANCE)
        b = @advance_old_player_y
        c = @advance_change_y
        @player.y = ease_in_out_quad(t, b, c, DURATION_ADVANCE)
      end
    end

    $window.caption = "FPS #{$window.fps} - " \
      "milliseconds_since_last_tick: #{$window.milliseconds_since_last_tick} - " \
      "game objects #{current_game_state.game_objects.size}"
  end

  def draw
    $window.translate(SCREEN_CENTER_X, SCREEN_CENTER_Y) do
      $window.translate(-@player.x, -@player.y) do
        $window.rotate(@player.angle, @player.x, @player.y) do
          @honeycomb.draw if @honeycomb
          super
        end
      end
    end
  end

  def advance
    if not moving?
      @advance_old_player_x = @player.x
      @advance_old_player_y = @player.y
      @advance_old_time = Gosu::milliseconds

      dist = Cell::RADIUS * Math.sqrt(3)
      @advance_change_x = offset_x(90 - @player.angle, dist)
      @advance_change_y = offset_y(90 - @player.angle, dist)
    end
  end

  def rotate_left
    if not moving?
      @rotation_old_player_angle = @player.angle
      @rotation_old_time = Gosu::milliseconds
      @rotation_change = ANGLE_STEP
    end
  end

  def rotate_right
    if not moving?
      @rotation_old_player_angle = @player.angle
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
