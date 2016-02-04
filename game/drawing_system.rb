module DrawingSystem
  class << self
    def init!
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

    def run!
      window = Entity.find("window")
      drawables = Entity.find_by(:@visible, :@tile_index, :@position)
      tiles = Entity.find_by(:@tile_index, :@tile_image).sort_by(&:tile_index)

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
  end
end
