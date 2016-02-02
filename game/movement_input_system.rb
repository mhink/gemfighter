class MovementInputSystem
  def run!
    case input_entity.input
    when "h" then move_by(Vector[-1,0])
    when "j" then move_by(Vector[0,1])
    when "k" then move_by(Vector[0,-1])
    when "l" then move_by(Vector[1,0])
    end
  end

  private
    def move_by(vector)
      movement_entities.each do |entity|
        entity.movement= vector
        entity.try(:messages).try(:<<, "Moved #{vector}")
      end
    end

    def input_entity
      Entity.instances_with(:@input).first
    end

    def movement_entities
      Entity.instances_with(:@movement)
    end
end
