require 'bitmap'

module MapSystem

  WALLS = "1111111111111111111111111100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000100000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011111111111111111111111111"
  MAP_SIZE= Size[25,19]

  class << self
    attr_reader :map
    def init!
      player = Entity.find("player")

      @map = Entity.find("map").set(
        size:            MAP_SIZE,
        entity_bitmap:   Bitmap[MAP_SIZE],
        wall_bitmap:     Bitmap[MAP_SIZE].from_s(WALLS),
        entity_children: [player]
      )
    end

    def check_entity_movement!
      @map.entity_children.each do |entity|
        next if entity.movement.nil?

        oldpos = entity.position
        newpos = entity.position + entity.movement
        ebm = @map.entity_bitmap
        wbm = @map.wall_bitmap
        cbm = (ebm | wbm)

        if cbm.in_bounds?(newpos) && !cbm[newpos]
          ebm[oldpos]= false
          ebm[newpos]= true
          entity.position += entity.movement
        else
          entity.movement = nil
        end
      end
    end
  end
end
