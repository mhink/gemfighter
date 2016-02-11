module DrawingSystem
  class << self
    def init!
      @tiles = Gosu::Image.load_tiles(
        RES_DIR.join("tiled-icons-16x16.png").to_s, 
        16, 16,
        retro: true)

      @tile_scale = Size[2,2]
    end

    N_STEPS = 5
    def prepare_tweens!
      @drawables ||= []
      @drawables.clear

      map   = Entity.find("map")
      gs    = map.grid_size
      wbm   = map.wall_bitmap
      ents  = map.entity_children

      wbm.each do |b, x, y|
        next unless b
        @drawables << {
          tile_index: 2,
          next_point: Point[x,y] * gs,
        }
      end

      ents.each do |entity|
        if entity.movement.nil?
          @drawables << {
            tile_index: entity.tile_index,
            next_point: (entity.position * gs)
          }
          next
        end

        b = entity.position - entity.movement
        m = entity.movement / N_STEPS.to_f
        points = (N_STEPS + 1).times.map { |t| (b + (m*t)) * gs }

        @drawables << {
          tile_index:   entity.tile_index,
          next_point:   points.shift,
          tween_points: points
        }
      end
    end

    def update_tweens!
      prepare_tweens! if @drawables.nil?
      @drawables.each do |drawable|
        if drawable.has_key?(:tween_points) && !drawable[:tween_points].empty?
          drawable[:next_point] = drawable[:tween_points].shift
        end
      end
    end

    def draw!
      prepare_tweens! if @drawables.nil?
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
  end
end
