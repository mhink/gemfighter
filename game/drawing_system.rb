module DrawingSystem
  N_STEPS = 5

  class << self
    def init!
      @tiles = Gosu::Image.load_tiles(
        RES_DIR.join("tiled-icons-16x16.png").to_s, 
        16, 16,
        retro: true)

      @tile_scale = Size[2,2]
    end

    def prepare_drawables!
      @drawables ||= []
      @drawables.clear

      walls = Entity.find("walls")
      actors = Entity.find("actors")
      items = Entity.find("items")

      self.send(walls.draw_with, walls)
      self.send(items.draw_with, items)
      self.send(actors.draw_with, actors)
    end

    def draw_walls(layer)
      layer.bitmap.each do |b, x, y|
        next unless b
        @drawables << {
          tile_index: 2,
          next_point: Point[x, y] * layer.grid_size,
        }
      end
    end

    def draw_actors(layer)
      entities_for_layer(layer).each do |actor|
        if actor.movement.nil?
          @drawables << {
            tile_index: actor.tile_index,
            next_point: (actor.position * layer.grid_size)
          }
        else
          b = actor.position - actor.movement
          m = actor.movement / N_STEPS.to_f
          gs = layer.grid_size
          points = (N_STEPS + 1).times.map { |t| (b + (m*t)) * gs }

          @drawables << {
            tile_index:   actor.tile_index,
            next_point:   points.shift,
            tween_points: points
          }
          actor.movement= nil
        end
      end
    end

    def draw_items(layer)
      entities_for_layer(layer).each do |item|
        @drawables << {
          tile_index: item.tile_index,
          next_point: (item.position * layer.grid_size)
        }
      end
    end

    def next_frame!
      prepare_drawables! if @drawables.nil?
      @drawables.each do |drawable|
        if drawable.has_key?(:tween_points) && !drawable[:tween_points].empty?
          drawable[:next_point] = drawable[:tween_points].shift
        end
      end
    end

    def draw!
      prepare_drawables! if @drawables.nil?
      @drawables.each do |drawable|
        draw_tile(drawable[:tile_index], drawable[:next_point])
      end
    end

    private
      def draw_tile(ix, pos)
        x, y   = pos.to_a
        sx, sy = @tile_scale.to_a
        img    = @tiles[ix]
        img.draw(x, y, 0, sx, sy)
      end

      def entities_for_layer(layer)
        Entity.find_by(:@layer_name).select do |entity|
          entity.layer_name == layer.name
        end
      end
  end
end
