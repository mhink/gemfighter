class MovementSystem
  def run!
    position_movement_entities.each do |entity|
      next unless entity.movement
      entity.position += entity.movement
      entity.movement = nil

      if entity.instance_variable_defined?(:@messages)
        entity.messages << "Entity moved to #{entity.position}"
      end
    end
  end

  private
    def position_movement_entities
      Entity.instances_with(:@position, :@movement)
    end
end
