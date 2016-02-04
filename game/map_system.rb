module MapSystem
  class << self
  def run!
    size = window_entity.size_tiles

    position_movement_entities.each do |entity|
      newpos = entity.position + entity.movement

      if(newpos.x < 0 || newpos.y < 0 || newpos.x >= size.x || newpos.y >= size.y)
        entity.movement= nil
      end
    end
  end

  private
    def window_entity
      Entity.find("window")
    end

    def position_movement_entities
      Entity.find_by(:@position, :@movement)
    end
  end
end
