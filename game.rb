require 'gosu'
require 'observer'
require 'pry'
require 'set'
require 'forwardable'

require_relative 'physics'
require_relative 'patches'
require_relative 'renderer'
require_relative 'fixed_object'
require_relative 'mobile_object'
require_relative 'collidables'
require_relative 'visuals'

# can't remember this math....
# class Velocity
#   def initialize
#     @angle = 0.0
#     @speed = 0
#   end

#   def change(direction, speed)
#     new_angle = case direction
#       when :right then 0.0
#       when :left  then 180.0
#       when :up    then 90.0
#       when :down  then 270.0
#     end
#   end

# end

# should position include dims?
class Position
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  def project(direction, distance)
    case direction
    when :left
      self.class.new(@x - distance, @y, @z)
    when :right
      self.class.new(@x + distance, @y, @z)
    when :up
      self.class.new(@x, @y - distance, @z)
    when :down
      self.class.new(@x, @y + distance, @z)
    end
  end
end

class Dimensions
  attr_accessor :width, :height

  def initialize(width, height)
    @width = width, @height = height
  end
end

class Window < Gosu::Window
  def initialize
    super(640, 480)
    self.caption = 'game time'

    @backgrounds = Dir["/home/sagotsky/.wallpaper/*.jpg"].first(2).map do |file|
      Gosu::Image.new file
    end 

    @renderer = Renderer.new(self)
    @player = Player.new
    @the_ground = FixedObject.new(0, 400, 100, 640)

    @current = 1
    @scale_x = 1
    @scale_y = 1

    @last_ms = 0
  end

  def update
    delta_time_update 
    input_update
    physics_update
    # log_update
  end

  def delta_time_update
    # gosu give us current ms, but not prev.  let's just attach it there.
    Gosu.send :remove_const, :DELTA if Gosu.const_defined?(:DELTA)
    Gosu.const_set(:DELTA, Gosu::milliseconds - @last_ms)
    @last_ms = Gosu::milliseconds
  end

  def log_update
    @last ||=0
    puts Gosu::milliseconds - @last
    @last = Gosu::milliseconds
  end

  def input_update
    [Gosu::KbDown, Gosu::KbUp, Gosu::KbLeft, Gosu::KbRight].each do |key|
      @player.unwalk unless Gosu::button_down?(key)
    end

    # multiple keys?
    if Gosu::button_down?(Gosu::KbRight)
      @player.walk :right
    end 

    if Gosu::button_down?(Gosu::KbLeft)
      @player.walk :left
    end 

    if Gosu::button_down?(Gosu::KbUp)
      # @player.walk :up
    end 

    if Gosu::button_down?(Gosu::KbDown)
      # @player.walk :down
    end

    if Gosu::button_down?(Gosu::KbSpace)
      @player.jump
    end

  end

  def physics_update
    Physics.call
  end

  def draw
    background.draw 0, 0, 0, @scale_x, @scale_y

    @renderer.draw @player
    @renderer.draw @the_ground
  end

  private

  def background
    @backgrounds[@current]
  end
end


Window.new.show
