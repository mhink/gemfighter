module PlayerSystem
  class << self
    def init!
      # A little proto-player entity.
      Entity.new("player",
        visible:    true,
        tile_index: 0,
        scale: Vector[2,2],
        movement:   nil,
        position:   Point[1,1])
    end

    def run!
      case input_entity.input
      when "h" then move_by(Vector[-1,0])
      when "j" then move_by(Vector[0,1])
      when "k" then move_by(Vector[0,-1])
      when "l" then move_by(Vector[1,0])

      when "y" then move_by(Vector[-1, -1])
      when "b" then move_by(Vector[-1,  1])
      when "u" then move_by(Vector[ 1, -1])
      when "n" then move_by(Vector[ 1,  1])
      end
    end

    def move_by(vector)
      player_entity.movement= vector
    end

    private
      def player_entity
        Entity.find("player")
      end

      def input_entity
        Entity.find("input")
      end
  end
end
