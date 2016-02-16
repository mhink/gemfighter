module PlayerSystem
  class << self
    def handle_player_input!
      player_entity.movement= nil
    end

    def check_hand(for_what)
      if player_entity.card_state.send(for_what).nil?
        puts "You have no #{for_what}!"
        throw :next_input
      end
    end

    def dump_inventory
      player_entity.inventory.each do |item|
        STDERR.puts(item.description)
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
