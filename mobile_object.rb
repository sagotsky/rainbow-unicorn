class MobileObject # this type of object inherits laws of physics.  other objects are mobile but don't.  maybe free/fixed objects?
  class << self
    # subclasses can register that they obey various laws of physics.
    # ie `physics :gravity, :friction`
    def physics(*laws)
      # class var will propogate down (which is correct)
      # will it go back up from player to MOb? (undesired)
      @@physics ||= Set.new
      laws.each {|law| @@physics << law }
      @@physics
    end
  end 

  extend Forwardable
  def_delegators :image, :height, :width
  def_delegators :@position, :x, :y, :z

  physics :gravity, :velocity, :friction

  attr_reader :x_scale, :y_scale
  attr_accessor :x_velocity, :y_velocity, :last_frame_ms

  def initialize(position = nil)
    @position = position || Position.new(0, 0, 1)
    @x_velocity = 0
    @y_velocity = 0 # are velocities prat of positoin?
    @last_frame_ms = Gosu::milliseconds
    setup_physics
    setup_visuals
  end 

  def move(direction, distance)
    new_pos = @position.project(direction, distance)
    # check it, then set it?
    # platform: change new pos.  truncate a fall
    # enemy: damage player
    # trampoline: add velocity to player
    # collisions = something(new_pos, bounding_box)
    new_pos.y = 400 - height if new_pos.y + height > 400
    @position = new_pos
  end

  def force(direction, delta, hmax: nil, vmax: nil)
    case direction
      when :left  then @x_velocity -= delta
      when :right then @x_velocity += delta
      when :up    then @y_velocity += delta
      when :down  then @y_velocity -= delta
    end 

    # action leading to force has a top speed: max
    # does character have a top speed distinct form that?
    if hmax
      @x_velocity = hmax if @x_velocity > hmax
      @x_velocity = -hmax if @x_velocity < -hmax
    end 

    if vmax
      @y_velocity = vmax if @y_velocity > vmax
      @y_velocity = -vmax if @y_velocity < -vmax
    end 
  end

  private

  def bounding_box
    # Box.new
    [x, y, width, height]
  end

  def setup_physics
    # Collidables.register(self)

    self.class.physics.each do |law|
      Physics[law].new(self)
    end
  end

  def setup_visuals
    Visuals.register self
  end
end

class Character < MobileObject
  # delegate coords to position
  
  def initialize
    super
    @dims = Dimensions.new(50, 100)

    @x_scale = 1.0
    @y_scale = 1.0

    @assets = Gosu::Image::load_tiles('unicorn-sprite.png', 150, 120)

    @moving = false
    @jumping = false
    @walk_speed = 10
  end

  def walk(direction)
    @moving = true
    face direction
    # move direction, @walk_speed
    force direction, 10, hmax: 15 # dir, delta, max
  end

  def unwalk
    @moving = false
  end

  def jump
    unless jumping?
      force :up, 50, vmax: 10 
      @jumped_at = Gosu::milliseconds
    end 
  end

  # doesn't account for landing..
  def jumping?
    return unless @jumped_at
    @jumped_at && (@jumped_at > Gosu::milliseconds - 500)
  end

  def face(direction)
    case direction
    when :left  
      new_x_scale = -1.0
      move(:right, width) if @x_scale != new_x_scale
      @x_scale = new_x_scale
    when :right 
      new_x_scale = 1.0
      move :left, width if @x_scale != new_x_scale
      @x_scale = new_x_scale
    end
  end

  def image
    # image controls w/h right now.  instead it should render based on obj's w/h.
    if @moving
      step = (Gosu::milliseconds/100 % @assets.size) 
      @assets[step] 
    else 
      @assets.first
    end 
  end
end



class Player < Character
  def fart
    speed = -10 # determined by facing direction
    Fart.new(position, speed, 0)
  end
end

class Projectile < MobileObject
  def initialize(position, x_velocity, y_velocity)
    @position = position
    @x_velocity = x_velocity
    @y_velocity = y_velocity
  end
end

class Fart < Projectile
  def geometry
    [x, y, Gosu::Color::GREEN,
     x + 10, y, Gosu::Color::RED,
     x, y + 3, Gosu::Color::YELLOW,
     x + 10, y + 3, Gosu::Color::BLUE,
    ]
  end
end
