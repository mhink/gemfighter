require 'bitmap'

module MapSystem

  class << self
    def check_entity_movement!
      map = Entity.find("map")
      map.entity_children.each do |entity|
        next if entity.movement.nil?

        oldpos = entity.position
        newpos = entity.position + entity.movement
        ebm = map.entity_bitmap
        wbm = map.wall_bitmap
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
