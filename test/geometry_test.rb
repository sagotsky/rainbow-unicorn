require 'test_helper'

class Geometry
  def overlaps

  end
end

class Point < Geometry
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Rectangle < Geometry
  attr_reader :x, :y, :w, :h

  def initialize(x, y, w, h)
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def tl
    Point.new(x, y)
  end

  def tr
    Point.new(x + w, y)
  end

  def bl
    Point.new(x, y+h)
  end

  def br
    Point.new(x+w, y+h)
  end

  def includes?(p)
    (
      x   <= p.x   &&
      p.x <= x + w &&
      y   <= p.y   &&
      p.y <= y + h
    )
  end
end

# how to add own class here?
describe Rectangle do
  let (:rectangle) do
    Rectangle.new(0, 0, 10, 10)
  end

  let (:point) do
    Point.new 5, 5
  end

  it 'includes a point' do
    assert rectangle.includes?(point)
  end

  it 'but not that one' do
    refute rectangle.includes?(Point.new 100, 100)
  end
end
