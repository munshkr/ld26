module Util
  def linear_tween(t, b, c, d)
    t = t.to_f; b = b.to_f; c = c.to_f; d = d.to_f
    c * t / d + b
  end

  def ease_in_out_quad(t, b, c, d)
    t = t.to_f; b = b.to_f; c = c.to_f; d = d.to_f

    t /= d / 2
    if (t < 1)
      return c / 2*t*t + b
    end
    t -= 1
    return -c/2 * (t*(t-2) - 1) + b
  end
end

if __FILE__ == $0
  include Util

  b = 0
  c = 100
  d = 1000

  1000.times do |t|
    v = ease_in_out_quad(t, b, c, d)
    #v = linear_tween(t, b, c, d)
    puts v
  end
end
