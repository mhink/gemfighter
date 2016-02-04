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
    init_window!
    init_tiles!
    window_entity.window.show
  end

  def run!
    window = window_entity
    tiles = tile_entities
    drawables = drawable_entities

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
    def init_window!
      window_size = Size[800, 600]
      window = Window.new(size: window_size)
      window.on_update(&@on_update_callback)
      window.on_draw(&@on_draw_callback)

      Entity.new("window",
                 window:     window,
                 size:       window_size, 
                 grid_size:  Size[32,32],
                 size_tiles: Size[25,18])
    end

    def init_tiles!
      tiles = Gosu::Image.load_tiles(
          RES_DIR.join("tiled-icons-16x16.png").to_s, 
          16, 16,
          retro: true)

      tiles.each_with_index do |img, ix|
        # Create an Entity for each tile
        Entity.new(tile_index: ix, 
                   tile_image: img)
      end
    end

    def tile_entities
      Entity.find_by(:@tile_index, :@tile_image).sort_by do |entity| 
        entity.tile_index
      end
    end

    def window_entity
      Entity.find("window")
    end

    def drawable_entities
      Entity.find_by(:@visible, :@tile_index, :@position)
    end
  end
end
