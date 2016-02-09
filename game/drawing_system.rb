module DrawingSystem
  class << self
    def init!
      player = Entity.find("player").set(
        tile_index: 0
      )

      map = Entity.find("map").set(
        grid_size:       Size[32,32],
        render_with:     :draw_map,
      )
    end

    N_STEPS = 5
    def prepare_tweens!
      @drawables ||= []
      @drawables.clear

      map   = Entity.find("map")
      tiles = Entity.find_by(:@tile_image, :@tile_index).sort_by(&:tile_index) 
      gs    = map.grid_size
      wbm   = map.wall_bitmap
      ents  = map.entity_children

      wbm.each do |b, x, y|
        next unless b
        @drawables << {
          tile:       tiles[2],
          next_point: Point[x,y] * gs,
        }
      end

      ents.each do |entity|
        if entity.movement.nil?
          @drawables << {
            tile:       tiles[entity.tile_index],
            next_point: entity.position * gs
          }
          next
        end

        oldpos = entity.position - entity.movement
        newpos = entity.position

        x_step = ((newpos.x - oldpos.x) / N_STEPS).to_f
        y_step = ((newpos.y - oldpos.y) / N_STEPS).to_f


        x_steps = if x_step == 0
                    [newpos.x].lazy.cycle(N_STEPS).map(&:to_f).to_a
                  elsif x_step < 0
                    (newpos.x..oldpos.x).step(-x_step).to_a.reverse
                  elsif x_step > 0
                    (oldpos.x..newpos.x).step(x_step).to_a
                  end

        y_steps = if y_step == 0
                    [newpos.y].lazy.cycle(N_STEPS).map(&:to_f).to_a
                  elsif y_step < 0
                    (newpos.y..oldpos.y).step(-y_step).to_a.reverse
                  elsif y_step > 0
                    (oldpos.y..newpos.y).step(y_step).to_a
                  end


        points = N_STEPS.times.map do |i|
          Point[x_steps[i], y_steps[i]] * gs
        end

        unless points.include? newpos
          points << (newpos * gs)
        end

        @drawables << {
          tile:         tiles[entity.tile_index],
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
        draw_tile(drawable[:tile], drawable[:next_point])
      end
    end

    private
      def draw_tile(tile, pos)
        x, y   = pos.to_a
        sx, sy = (tile.scale || [1,1]).to_a
        img    = tile.tile_image
        img.draw(x, y, 0, sx, sy)
      end
  end
end
