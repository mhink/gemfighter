require 'window'

module WindowSystem
  class << self
  def on_update(&block)
    @on_update_callback = block
  end

  def on_draw(&block)
    @on_draw_callback = block
  end

  def start
    wnd = Window.new(size: window_entity.size)
    window_entity.window = wnd
    wnd.on_update(&@on_update_callback)
    wnd.on_draw(&@on_draw_callback)
    wnd.show
  end

  # Perhaps #run! isn't as great for these methods, since
  # we need to distinguish between 'stuff that happens during
  # update' and 'stuff that happens during rendering'.
  #
  # The question is, should this be a system-level distinction
  # or a method-level distinction?
  def run!
    drawables = drawable_entities
    tiles = tile_entities
    window = window_entity

    font = Gosu::Font.new(12, name: "Arial")

    drawables.each do |entity|
      x, y = entity.position.to_a
      tx, ty = window.grid_size.to_a
      sx, sy = (entity.scale.nil? ? [1,1] : entity.scale.to_a)
      tile = tiles[entity.tile_index]
      tile_image = tile.tile_image
      tile_image.draw((x * tx), (y * ty), 0, sx, sy)
      font.draw(tile.tile_index.to_s, (x * tx), (y * ty), 0)
    end
  end

  def stop
    window_entity.window.close
  end

  private
    def tile_entities
      Entity.instances_with(:@tile_index, :@tile_image).sort_by do |entity| 
        entity.tile_index
      end
    end

    def window_entity
      Entity.instances_with(:@size, :@window).first
    end

    def drawable_entities
      Entity.instances_with(:@visible, :@tile_index, :@position)
    end
  end
end
