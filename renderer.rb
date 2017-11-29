# draws an object.  object must provide x,y,z, and image
class Renderer
  class << self
    def <<(object)
      renderables << object
    end

    def renderables
      @renderables ||= Set.new
    end

  end

  def initialize(screen)
    @screen = screen
  end

  def draw_all
    self.class.renderables.each do |object|
      draw object
    end
  end

  # does a game object need a different name?
  def draw(object)
    case
    when object.respond_to?(:image)
      draw_image(object)
    when object.respond_to?(:geometry)
      draw_geometry(object)
    when object.respond_to?(:draw)
      object.draw(@screen) # should objects handle own drawing?  this one wants to do something special.  do others?
    else
      raise "cannot draw object #{object}"
    end
  end

  private

  def draw_image(object)
    object.image.draw(object.x, object.y, object.z, object.x_scale, object.y_scale)
  end

  def draw_geometry(object)
    @screen.draw_quad *object.geometry
  end

end
