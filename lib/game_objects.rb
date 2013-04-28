class Cell < Chingu::GameObject
  RADIUS = 64
  DIAMETER = RADIUS * 2
  WALL_WIDTH = 5

  COLOR = Color::WHITE
  COLOR.alpha = 60

  attr_accessor :walls

  def initialize(options={})
    super(options.merge(image: self.class.cell_image))
    self.walls = options[:walls]
  end

  def draw
    super
    draw_walls
  end

  def draw_walls
    walls.each do |wall|
      self.class.wall_image(wall).draw(self.x - RADIUS,
                                       self.y - RADIUS * (Math.sqrt(3) / 2.0), 0)
    end
  end

  def self.cell_image
    @cell_image ||= begin
      image = TexPlay.create_blank_image($window, DIAMETER + 1, DIAMETER + 1)
      image.paint do
        ngon RADIUS, RADIUS, RADIUS, 6, thickness: 2, color: COLOR
      end
      image
    end
  end

  def self.wall_image(wall)
    @wall_images ||= {}
    @wall_images[wall] ||= begin
      image = TexPlay.create_blank_image($window, DIAMETER + 1, DIAMETER + 1)
      image.paint do
        case wall
        when :right
          line RADIUS * 1.5, 0,
               RADIUS * 2,   RADIUS * Math.sqrt(3) / 2.0,
               thickness: WALL_WIDTH, color: Color::GREEN
        when :down
          line RADIUS * 2,   RADIUS * Math.sqrt(3) / 2.0,
               RADIUS * 1.5, RADIUS * Math.sqrt(3),
               thickness: WALL_WIDTH, color: Color::GREEN
        when :down_left
          line RADIUS * 0.5, RADIUS * Math.sqrt(3),
               RADIUS * 1.5, RADIUS * Math.sqrt(3),
               thickness: WALL_WIDTH, color: Color::GREEN
        when :left
          line RADIUS * 0.5, RADIUS * Math.sqrt(3),
               0,            RADIUS * Math.sqrt(3) / 2.0,
               thickness: WALL_WIDTH, color: Color::GREEN
        when :up_left
          line 0,            RADIUS * Math.sqrt(3) / 2.0,
               RADIUS * 0.5, 0,
               thickness: WALL_WIDTH, color: Color::GREEN
        when :up
          line RADIUS * 0.5, 0,
               RADIUS * 1.5, 0,
               thickness: WALL_WIDTH, color: Color::GREEN
        end
      end
      image
    end
  end
end

class Honeycomb
  CELL_DISTANCE_X = Cell::DIAMETER * 3 / 2.0
  CELL_DISTANCE_Y = Cell::RADIUS * Math.sqrt(3) / 2.0
  CELL_OFFSET_X_EVEN_ROW = CELL_DISTANCE_X / 2.0

  NUM_CELLS = 8

  attr_reader :cells

  def initialize(options={})
    @cells = []

    offset_x = -(Cell::DIAMETER * 3 / 4.0)
    offset_y = 0

    (-NUM_CELLS .. NUM_CELLS).each do |j|
      row = []

      (-NUM_CELLS .. NUM_CELLS).each do |i|
        x = offset_x + i * CELL_DISTANCE_X
        if j % 2 == 0
          x += CELL_OFFSET_X_EVEN_ROW
        end
        y = offset_y + (j * CELL_DISTANCE_Y)

        cell = new_cell(x, y)

        if i == 0 and j == 0
          cell.image = TexPlay.create_blank_image($window, Cell::DIAMETER + 1, Cell::DIAMETER + 1)
          cell.image.paint do
            ngon Cell::RADIUS, Cell::RADIUS, Cell::RADIUS, 6, thickness: 3, color: Color::BLUE
          end
        end

        row << cell
      end

      @cells << row
    end
  end

  # This generates a new row and column of cells in the direction of the
  # movement, and deletes another row and column in the oposite direction
  def move(cx, cy)
    # append and insert new columns on each row
    @cells.each do |row|
      row.unshift(new_cell(row.first.x - CELL_DISTANCE_X, row.first.y))
      row << new_cell(row.last.x + CELL_DISTANCE_X, row.last.y)
    end

    # append and insert new rows
    2.times do
      new_row = @cells.first.map { |c| new_cell(c.x + (@cells.size % 2 == 0 ? -1 : 1) * CELL_OFFSET_X_EVEN_ROW, c.y - CELL_DISTANCE_Y) }
      @cells.unshift(new_row)

      new_row = @cells.last.map { |c| new_cell(c.x + (@cells.size % 2 == 0 ? -1 : 1) * CELL_OFFSET_X_EVEN_ROW, c.y + CELL_DISTANCE_Y) }
      @cells << new_row
    end

    @cells.each do |row|
      row.delete_if do |c|
        (cx - c.x).abs > SCREEN_WIDTH ||
        (cy - c.y).abs > SCREEN_HEIGHT
      end
    end
    @cells.delete_if { |r| r.empty? }

    puts "rows: #{@cells.size}, cols: #{@cells.first.size}"
  end

  def draw
    @cells.each do |row|
      row.each { |c| c.draw }
    end
  end

  def new_cell(x, y)
    Cell.new(x: x, y: y, walls: random_walls)
  end

  # NOTE temporal
  def random_walls(factor=6)
    walls = []
    [:right, :down, :down_left, :left, :up_left, :up].each do |wall|
      walls << wall if rand(factor).zero?
    end
    walls
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
end
