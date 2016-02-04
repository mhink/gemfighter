require 'bitmap'

module MapSystem
  class << self
    def init!
      player = Entity.find("player").set(
        position: Point[1,1],
        movement: nil)

      map = Entity.new("map", 
        wall_tile_index:  2,
        wall_bitmap:   Bitmap[25,19],
        entity_bitmap: Bitmap[25,19],
        map_children: Set.new([player]),
        render_with: "MapSystem#draw_map")

      def map.collision_bitmap
        (@wall_bitmap | @entity_bitmap)
      end

      def map.drawable_wall_bitmap
        (@wall_bitmap & ~@entity_bitmap)
      end

      map.wall_bitmap[5,5] = true

      Entity.find("window").render_children << map
    end

    def check_entity_movement!
      map = Entity.find("map")

      map.map_children.each do |entity|
        validate_child(entity)
        entity_bitmap = map.entity_bitmap
        bitmap = map.collision_bitmap
        oldpos = entity.position
        newpos = entity.position + entity.movement

        if bitmap.in_bounds?(newpos) && !bitmap[newpos]
          entity_bitmap[oldpos]= false
          entity_bitmap[newpos]= true
          entity.position += entity.movement
        end

        entity.movement= nil
      end
    end

    def draw_map
      window = Entity.find("window")
      map = Entity.find("map")
      tiles = Entity.find_by(:@tile_image, :@tile_index).sort_by(&:tile_index)

      drawable_walls    = map.drawable_wall_bitmap
      drawable_entities = map.map_children
      wall_tile         = tiles[map.wall_tile_index]

      drawable_walls.each do |b, x, y|
        next unless b
        draw_tile(wall_tile, [x,y], window.grid_size)
      end

      drawable_entities.each do |entity|
        tile = tiles[entity.tile_index]
        draw_tile(tile, entity.position, window.grid_size)
      end
    end

    private
      def draw_tile(tile, pos, grid_size)
        x,  y = pos.to_a
        tx, ty = grid_size.to_a
        sx, sy = (tile.scale || [1,1]).to_a
        img    = tile.tile_image
        img.draw((x * tx), (y * ty), 0, sx, sy)
      end

      def find_tile_by_index(ix)
        Entities.find(:@tile_image).find do |tile|
          tile.tile_index = ix
        end
      end

      def validate_child(entity)
        unless entity.instance_variable_defined? :@position
          raise "Map: #{map.to_s} has child entities which don't have a @position component!"
        end
        unless entity.instance_variable_defined? :@movement
          raise "Map: #{map.to_s} has child entities which don't have a @movement component!"
        end
      end
  end
end
