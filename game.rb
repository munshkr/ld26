require "chingu"
include Gosu

class GameWindow < Chingu::Window
  def initialize
    super

    self.input = {
      [:escape] => :exit,
    }
  end
end


if __FILE__ == $0
  GameWindow.new.show
end
