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
    draw_image(object) if object.respond_to?(:image)
    draw_geometry(object) if object.respond_to?(:geometry)
  end

  private

  def draw_image(object)
    object.image.draw(object.x, object.y, object.z, object.x_scale, object.y_scale)
  end

  def draw_geometry(object)
    @screen.draw_quad *object.geometry
  end

end
