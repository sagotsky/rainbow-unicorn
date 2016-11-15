# as mobile object
class FixedObject
  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
    @z = 100
  end

  # one quad per object seems dumb...
  def geometry
    [ @x, @y, Gosu::Color::GREEN, 
      @x + @height, @y, Gosu::Color::GREEN,
      @x, @y + @width, Gosu::Color::YELLOW,
      @x + @height, @y + @width, Gosu::Color::YELLOW,
      @z
    ]
  end
end

