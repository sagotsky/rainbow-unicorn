# as mobile object
class FixedObject
  class << self
    def all
      @all ||= Set.new
    end
  end

  attr_reader :x, :y, :width, :height

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
    @z = 100
    Renderer << self
    FixedObject.all << self
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

  def on_screen?
    true
  end
end

# class FixedImage
#   attr_reader :x, :y, :width, :height, :z, :x_scale, :y_scale
#   def initialize(x, y, w, h, image)
#     @x = x
#     @y = y
#     @width = w
#     @height = h
#     @image = Gosu::Image::load_tiles(image, 135, 100)
#     @z = 10
#     size = (Random.rand + 0.5)/2
#     @x_scale = size
#     @y_scale = size
#     Renderer << self
#   end

#   def image
#     @image.first
#   end
# end

# # class Poop < FixedImage
# #   physics :gravity

# # end
