module DrawingSystem
  N_STEPS = 5

  class << self
    def init!
      @tiles = Gosu::Image.load_tiles(
        RES_DIR.join("tiled-icons-16x16.png").to_s, 
        16, 16,
        retro: true)

      @tile_scale = Size[2,2]
      @grid_size  = Size[32,32]
    end

    def prepare_drawables!
      @drawables ||= []
      @drawables.clear

      @drawables.concat(wall_sprites)
      @drawables.concat(item_sprites)
      @drawables.concat(actor_sprites)
    end

    def wall_sprites
      walls = Entity.find("walls")
      walls.bitmap.active_coords.map do |pt|
        { 
          tile_index: 2, 
          coord: pt 
        }
      end
    end

    def item_sprites
      items     = Entity.find("items")
      entities_for_layer(items).map do |item|
        {
          tile_index: item.tile_index,
          coord: item.position 
        }
      end
    end

    def actor_sprites
      actors = Entity.find("actors")
      entities_for_layer(actors).map do |actor|
        if actor.movement.nil?
          {
            tile_index: actor.tile_index,
            coord: (actor.position)
          }
        else
          b = actor.position - actor.movement
          m = actor.movement / N_STEPS.to_f
          points = (N_STEPS + 1).times.map { |t| (b + (m*t)) }

          {
            tile_index:     actor.tile_index,
            coord:          points.shift,
            tweened_coords: points
          }
        end
      end
    end

    def next_frame!
      prepare_drawables! if @drawables.nil?
      @drawables.each do |drawable|
        if drawable.has_key?(:tweened_coords) && !drawable[:tweened_coords].empty?
          drawable[:coord] = drawable[:tweened_coords].shift
        end
      end
    end

    def draw!
      prepare_drawables! if @drawables.nil?

      map_viewport = Entity.find("map_viewport")

      @drawables.each do |drawable|
        draw_tile(drawable[:tile_index], drawable[:coord] * @grid_size)
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
