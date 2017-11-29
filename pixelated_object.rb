# experiment to see if we can fake something being pixelated and have it look good.
class PixelatedObject
  def initialize(x, y, w, h)
    @px_size = 20
    @x = x
    @y = y
    @w = w
    @h = h
    @bw = 2
    Renderer << self
  end

  def push
    @px_size -= 2
  end

  def pull
    @px_size += 2
  end


  def draw(screen)
    # background
    black = Gosu::Color::BLACK
    screen.draw_quad(
      @x-1, @y-1, black,
      @x + @w, @y-1, black,
      @x-1, @y + @h, black,
      @x + @w + 2, @y + @h + 2, black,
      2
    )
    pixel_geometry.each do |row| # doesn't have to be a row
      row.each do |cell|
        screen.draw_quad *cell
      end
    end
  end

  def color
    @color
  end

  private

  def pixel_geometry
    (0 .. @w/@px_size).map do |ww|
      (0 .. @h/@px_size).map do |hh|
        xx = @x + ww * @px_size
        yy = @y + hh * @px_size # omg these names
        px = @px_size - @bw # border
        color = [ Gosu::Color::RED, Gosu::Color::YELLOW, Gosu::Color::BLUE, Gosu::Color::GREEN ].last(2).sample
        geometry = [
          xx              , yy      , color ,
          xx + px         , yy      , color ,
          xx              , yy + px , color ,
          xx + px         , yy + px , color ,
          1000 # z dpeth?
        ]
      end
    end
  end
end
