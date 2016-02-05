require 'bitmap'

module MapSystem
  class << self
    attr_reader :map
    def init!
      @map = Entity.find("map")
    end

    def check_entity_movement!
      @map.entity_children.each do |entity|
        oldpos = entity.position
        newpos = entity.position + entity.movement
        cbm = collision_bitmap(@map)

        if cbm.in_bounds?(newpos) && !cbm[newpos]
          @map.bitmap[oldpos]= false
          @map.bitmap[newpos]= true
          entity.position += entity.movement
        end

        entity.movement= nil
      end
    end

    private
      def collision_bitmap(entity)
        bitmap = entity.bitmap
        if entity.has?(:bitmap_children)
          entity.bitmap_children.each do |bmc|
            bitmap |= collision_bitmap(bmc)
          end
        end
        bitmap
      end

      def find_tile_by_index(ix)
        Entities.find(:@tile_image).find do |tile|
          tile.tile_index = ix
        end
      end
  end
end
