#! /usr/bin/env ruby
# let's see what chipmunk buys us

require 'gosu'
require 'pry'
require 'chipmunk'
require 'forwardable'

class GameWindow < Gosu::Window
  PHYSICS_TICKS=1
  GRAVITY=400

  def initialize
    super(1600, 900)
    self.caption = 'working title'

    @space = CP::Space.new
    @space.gravity = CP::Vec2.new 0.0, GRAVITY

    @background = Gosu::Image.new('assets/sunset.png')

    @renderables = []
    @space.add_collision_func :projectile, :projectile do |a, b, arbiter|
      binding.pry
    end


    return

    CollisionMap.all.each do |(a, b), block|
      # @space.add_collision_func a, b, block
      @space.add_collision_func a, b do |*args|
        binding.pry # generic blcok maybe?
      end
    end
  end

  def draw
    @background.draw 0, 0, 0, 1, 1
    @renderables.each &:draw
  end

  # need a better term tha object
  def add_object(obj)
    @space.add_body obj.body
    @space.add_shape obj.shape
    @renderables << obj
  end

  def update
    PHYSICS_TICKS.times do
      @space.step 10.0/600 #
    end
  end
end

module VectorsBuilder
  # [1,2,3,4,...] => [CP::Vec2.new(1,2), CP::Vec2.new(3,4), ...]
  def self.vec2(*xy_s)
    xy_s.each_slice(2).map do |pair|
      CP::Vec2.new(*pair)
    end
  end
end

module CollisionMap
  def self.all
    {
      [:projectile, :projectile] => CollisionHandler,
      [:___projectile, :projectile] => Proc.new do |a, b|
        puts 'collision'
      end
    }
  end
end


class CollisionHandler
  def begin(a, b, handler)
    binding.pry
  end
end



class Entity
  SPEED_LIMIT = 500.freeze
  IMAGE_FILE = nil.freeze # string me!
  A = 1
  B = 1
  COLOR = Gosu::Color::RED

  attr_reader :body, :w, :h

  def initialize window, x, y
    @body = CP::Body.new self.class::A, self.class::B
    @body.p = CP::Vec2.new x, y
    @body.v_limit = self.class::SPEED_LIMIT
    @image = Gosu::Image.new(self.class::IMAGE_FILE) if self.class::IMAGE_FILE

    window.add_object self
  end

  def draw
    draw_image
    draw_color
    draw_outline
  end

  private

  def draw_image
    @image.draw @body.p.x, @body.p.y, 1 if @image
  end

  def draw_color
    return if @image

    args = bounding_rect.flat_map do |vec|
      [vec.x + x, vec.y + y, self.class::COLOR]
    end
    $w.draw_quad *args, 1
  end

  # draw a bunch of quads around object.
  # starting with a line, then a square, then actual shape.
  def draw_outline
    # can we just read in the image to figure out bounds?
    outline_points = bounds.zip(bounds.rotate)
    outline_points.each_with_index do |(a, b), i|
      color = Gosu::Color.rgb(i * 20, 255 - i*20, 100)

      draw_thick_line(
        x + a.x, y + a.y,
        x + b.x, y + b.y,
        color
      )
    end
  end

  def draw_thick_line(x1, y1, x2, y2, color, thickness: 6)
    thickness.times do |t|
      $w.draw_line(
        (x1 + t), y1 + t, Gosu::Color::BLACK,
        (x2 + t), y2 + t, Gosu::Color::BLACK,
        2
      )
    end
  end
end

class Cannonball < Entity
  SPEED_LIMIT = 500
  IMAGE_FILE = nil # 'unicorn-poop.png'
  A = 500
  B = 500

  extend Forwardable

  def_delegators :@body,
    :apply_force, :apply_impulse, :p

  def_delegators :p,
    :x, :y

  def bounds
    VectorsBuilder.vec2(
      0, 0,
      0, 50,
      50, 50,
      50, 0
    )

    VectorsBuilder.vec2(
      25, 0,
      0, 25,
      0, 50,
      25, 75,
      50, 75,
      75, 50,
      75, 25,
      50, 0,
    )
  end

  # grabs min/max of all bounds, builds out rect.  maybe useful?
  def bounding_rect
    xs = bounds.map &:x
    ys = bounds.map &:y

    VectorsBuilder.vec2(
      xs.min, ys.min,
      xs.min, ys.max,
      xs.max, ys.max,
      xs.max, ys.min,
    )
  end

  def shape
    bounding_rect
    @shape ||= begin

      # CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0)).tap do |shape|
      CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0)).tap do |shape|
        shape.collision_type = :projectile
      end
    end
  end
end

class Turd < Entity
  A = 500 # no idea what these are
  B = 500
  IMAGE_FILE = 'unicorn-poop.png'

  def initialize(window, x, y)
    super

    @width = 100
    @height = 200
  end

  def x
    @body.p.x
  end

  def y
    @body.p.y
  end


  def draw
    @image.draw @body.p.x, @body.p.y, 1
    draw_outline
  end

  # def bounds
  #   @bounds ||= VectorsBuilder.vec2(
  #     -13, -6,
  #     -16, -4,
  #     -16, 6,
  #     -3, 12,
  #     8, 12,
  #     13, 10,
  #     16, 3,
  #     16, -4,
  #     10, -9,
  #     2, -11,
  #   )
  # end

  # can't use image.  it's convex.
  # start at top, go counter clockwise.  to do this, go top to bottom grabbing right most item.  then bottom to top grabbing left most.
  #
  def bounds
      str = <<~TXT
                 *

        *             *

      *             *

          *      *
      TXT

      # str = <<~TXT
      # *
# *


# *                                *

      #                               *
   # *                               *
      #     *               *
      # TXT

     a = str.each_line.map.with_index do |line, i|
       pos = line.index '*'
       [pos, i] if pos
     end

     max_i = str.split("\n").size - 1
     b = str.each_line.reverse_each.map.with_index do |line, i|
       pos = line.rindex '*'
       [pos, max_i - i] if pos
     end

     s = (a + b).uniq.compact

     VectorsBuilder.vec2 *s.flatten.map { |i| i * 10 if i } # scale up shape
  end

  def shape

    @shape ||= begin

      # todo: string based bounding boxes???
      # find center, extrapolate from there?

      # CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0)).tap do |shape|
      CP::Shape::Poly.new(@body, bounds, CP::Vec2.new(0, 0)).tap do |shape|
        shape.collision_type = :projectile
      end
    end
  end
end

$w = GameWindow.new
c1 = Cannonball.new $w, 10, 100
# t1 = Turd.new $w, 10, 200
# t2 = Turd.new $w, 150, 200
# t2.apply_impulse CP::Vec2.new(-2000.0, -1000.0), CP::Vec2.new(200000, 200000)
# binding.pry # can add force?
$w.show


