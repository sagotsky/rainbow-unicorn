# world phsyics
class Physics
  extend Observable

  def initialize(object)
    @object = object
    self.class.add_observer self
  end

  def self.call
    descendants.each &:changed
    descendants.each &:notify_observers
  end

  def self.[](law)
    const_get(law.capitalize)
  end

  def update
    raise 'implement update on your physics subclass'
  end
end

#TODO
class Physics::Gravity < Physics
  THE_CONSTANT_DOWNWARD_PULL = 7

  def update
    # @object.move :down, THE_CONSTANT_DOWNWARD_PULL
    # this should also tick per frame
    # @object.force :down, THE_CONSTANT_DOWNWARD_PULL
    dt = Gosu::DELTA
    @object.force :down, dt / 15
  end
end

class Physics::Velocity < Physics
  #TODO
  def update
    # what happens to an object with up 2 that gains up 3?  how about down 2?
    # @object.velocities.each do |direction, speed|
    #   @object.move direction, sped
    # end

    dt = Gosu::DELTA
    x = dt * @object.x_velocity / 15
    y = dt * @object.y_velocity / 15
    # wtf is this 15?  confused by lack of units.

    @object.move :right, x
    @object.move :up, y

    @object.last_frame_ms = Gosu::milliseconds
  end
end

class Physics::Friction < Physics
  # walking on ground should slow player
  # walking on platform should be just like ground
  # moving platform should not slip away from player, but have otherwise normal friction.


  def update
    # object.touching.map(&:frictions).each...
    if @object.x_velocity > 0
      @object.x_velocity -= 1
    end

    if @object.x_velocity < 0
      @object.x_velocity += 1
    end
  end

  # is wall friciton a thang?
end

class Physics::Ground < Physics
  # early attempt at a static collidable
  # probably going to go away after this informs us a bit better about collisions

  def update
    bottom = @object.y + @object.height
    ground_y = @@window.floor - 100

    if bottom > ground_y
      @object.move :up, bottom - ground_y
      @object.y_velocity = 0
    end
  end
end

class Physics::Platforms < Physics
  def update
    # loop over all the platofmrs.  see if we overlap.
    # only platforms on screen?
    platforms = FixedObject.all.select(&:on_screen?)
    # do we care what type of collision happens?  is going up different than down?

    platforms.select do |p|
      # let's just be explicit about squares for now.
      a = Square.new(p.x, p.y, p.width, p.height)
      b = Square.new(@object.x, @object.y, @object.w, @object.h)
      Geometry.overlaps? a, b



    end

  end
end
