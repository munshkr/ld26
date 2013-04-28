class Honeycomb
  attr_reader :cells

  def initialize(options={})
    @cells = []

    offset_x = -(Cell::DIAMETER * 3 / 4.0)
    offset_y = 0

    (-16 .. 16).each do |i|
      (-16 .. 16).each do |j|
        x = offset_x + i * (Cell::DIAMETER * 3 / 2.0)
        if j % 2 == 0
          x += Cell::DIAMETER * 3 / 4.0
        end
        y = offset_y + (j * (((Cell::RADIUS) * Math.sqrt(3)) / 2.0))

        cell = Cell.new(x: x, y: y)

        if i == 0 and j == 0
          cell.image = TexPlay.create_blank_image($window, Cell::DIAMETER + 1, Cell::DIAMETER + 1)
          cell.image.paint do
            ngon Cell::RADIUS, Cell::RADIUS, Cell::RADIUS, 6, thickness: 3, color: Color::BLUE
          end
        end

        add_random_gates(cell)
        @cells << cell
      end
    end
  end

  def draw
    @cells.each { |c| c.draw }
  end

  # NOTE temporal
  def add_random_gates(cell)
    cell.gates = []
    [:right, :down, :down_left, :left, :up_left, :up].each do |gate|
      cell.gates << gate if rand(6).zero?
    end
  end
end

class Cell < Chingu::GameObject
  RADIUS = 64
  DIAMETER = RADIUS * 2
  GATE_WIDTH = 5

  COLOR = Color::WHITE
  COLOR.alpha = 60

  attr_accessor :gates

  def initialize(options={})
    super(options.merge(image: self.class.cell_image))
  end

  def draw
    super
    draw_gates
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

  def self.gate_image(gate)
    @gate_images ||= {}
    @gate_images[gate] ||= begin
      image = TexPlay.create_blank_image($window, DIAMETER + 1, DIAMETER + 1)
      image.paint do
        case gate
        when :right
          line RADIUS * 1.5, 0,
               RADIUS * 2,   RADIUS * Math.sqrt(3) / 2.0,
               thickness: GATE_WIDTH, color: Color::GREEN
        when :down
          line RADIUS * 2,   RADIUS * Math.sqrt(3) / 2.0,
               RADIUS * 1.5, RADIUS * Math.sqrt(3),
               thickness: GATE_WIDTH, color: Color::GREEN
        when :down_left
          line RADIUS * 0.5, RADIUS * Math.sqrt(3),
               RADIUS * 1.5, RADIUS * Math.sqrt(3),
               thickness: GATE_WIDTH, color: Color::GREEN
        when :left
          line RADIUS * 0.5, RADIUS * Math.sqrt(3),
               0,            RADIUS * Math.sqrt(3) / 2.0,
               thickness: GATE_WIDTH, color: Color::GREEN
        when :up_left
          line 0,            RADIUS * Math.sqrt(3) / 2.0,
               RADIUS * 0.5, 0,
               thickness: GATE_WIDTH, color: Color::GREEN
        when :up
          line RADIUS * 0.5, 0,
               RADIUS * 1.5, 0,
               thickness: GATE_WIDTH, color: Color::GREEN
        end
      end
      image
    end
  end

  def draw_gates
    gates.each do |gate|
      self.class.gate_image(gate).draw(self.x - RADIUS, self.y - RADIUS * (Math.sqrt(3) / 2.0), 0)
      #self.class.gate_image(gate).draw(self.x, self.y, 0)
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
