require "chingu"

class MinimalGameObject < Chingu::GameObject
  def initialize(*args)
    super

    setup
    @image = $window.record(@width, @height) do
      render
    end
  end

  def render
  end
end
