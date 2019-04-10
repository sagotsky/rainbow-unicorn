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
      @space.step 1.0/600 #
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

  def initialize window, x, y, w = 100, h = 100
    @body = CP::Body.new x, y # self.class::A, self.class::B
    @body.p = CP::Vec2.new x, y
    @body.v_limit = self.class::SPEED_LIMIT
    @image = Gosu::Image.new(self.class::IMAGE_FILE) if self.class::IMAGE_FILE
    @w = w.to_f
    @h = h.to_f

    window.add_object self
  end

  def draw
    @body.angle += 1

    # Gosu.rotate @body.angle, @body.p.x + @image.width/2, @body.p.y + @image.height/2 do
    Gosu.rotate @body.angle, mid_pt.x, mid_pt.y do
      draw_image
      draw_color
      draw_poly
      draw_outline
    end
  end

  private

  def mid_pt
    CP::Vec2.new @body.p.x + w/2, @body.p.y + h/2
  end

  def scale_x
    w / @image.width
  end

  def scale_y
    h / @image.height
  end

  def draw_image
    @image.draw @body.p.x, @body.p.y, 1, scale_x, scale_y  if @image
    # @image.draw_rot @body.p.x, @body.p.y, 1, @body.angle   if @image
    # @image.draw_rot @body.p.x, @body.p.y, 1, @angle  * 180 / Math::PI if @image
  end

  # just the bounding rect
  def draw_color
    # return if @image

    args = bounding_rect.flat_map do |vec|
      [vec.x + x, vec.y + y, self.class::COLOR]
    end
    Gosu.draw_quad *args, 1
  end

  def draw_poly
    bounds.zip(bounds.rotate).each do |(a, b)|
      Gosu.draw_triangle(
        a.x + x, a.y + y, self.class::COLOR,
        b.x + x, b.y + y, self.class::COLOR,
        x, y, self.class::COLOR,
      )
    end
  end

  # draw a bunch of quads around object.
  # starting with a line, then a square, then actual shape.
  def draw_outline
    # can we just read in the image to figure out bounds?
    outline_points = bounds.zip(bounds.rotate)
    max_x = outline_points.flatten.map(&:x).max
    max_y = outline_points.flatten.map(&:y).max

    outline_points.each_with_index do |(a, b), i|
      color = Gosu::Color.rgb(i * 20, 255 - i*20, 100)

      draw_thick_line(
        mid_pt.x + a.x - max_x / 2, mid_pt.y + a.y - max_y / 2,
        mid_pt.x + b.x - max_x / 2, mid_pt.y + b.y - max_y / 2,
        color
      )
    end
  end

  def draw_thick_line(x1, y1, x2, y2, color, thickness: 1)
    thickness.times do |t|
      Gosu.draw_line(
        (x1 + t), y1 + t, Gosu::Color::GREEN,
        (x2 + t), y2 + t, Gosu::Color::GREEN,
        2
      )
    end
  end
end

class Cannonball < Entity
  SPEED_LIMIT = 500
  IMAGE_FILE = 'unicorn-poop.png'
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

GameWindow.new.tap do |w|
  Cannonball.new w, 10, 100, 50, 50
  Cannonball.new w, 100, 100, 200, 200
  w.show
end

