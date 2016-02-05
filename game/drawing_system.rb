module DrawingSystem
  class << self
    def draw!
      draw_entity(Entity.find("render_root"), nil)
    end
    private
      def draw_entity(entity, parent)
        if entity.has?(:render_with)
          self.send(entity.render_with.to_sym, entity, parent)
        end

        if entity.has?(:render_children)
          entity.render_children.each do |child|
            draw_entity(child, entity)
          end
        end
      end

      def draw_map(entity, parent)
        @was_drawn = Bitmap.new(entity.size)
      end

      def draw_bitmap(entity, parent)
        tiles = Entity.find_by(:@tile_image, :@tile_index).sort_by(&:tile_index) 
        tile  = tiles[entity.tile_index]
        entity.bitmap.each do |b, x, y|
          next unless b
          draw_tile(tile, [x,y], parent.grid_size)
        end
      end

      def draw_map_entity(entity, parent)
        tiles = Entity.find_by(:@tile_image, :@tile_index).sort_by(&:tile_index)
        tile = tiles[entity.tile_index]
        draw_tile(tile, entity.position, parent.grid_size)
      end

      def draw_tile(tile, pos, grid_size)
        x,  y = pos.to_a
        return if @was_drawn[x, y]
        tx, ty = grid_size.to_a
        sx, sy = (tile.scale || [1,1]).to_a
        img    = tile.tile_image
        img.draw((x * tx), (y * ty), 0, sx, sy)
        @was_drawn[x,y]= true
      end
  end
end
