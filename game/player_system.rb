module PlayerSystem
  class << self
    def handle_player_input!
      player_entity.movement= nil
      case input_entity.input
      when "h" then move_by(Vector[-1,0])
      when "j" then move_by(Vector[0,1])
      when "k" then move_by(Vector[0,-1])
      when "l" then move_by(Vector[1,0])
      when "y" then move_by(Vector[-1, -1])
      when "b" then move_by(Vector[-1,  1])
      when "u" then move_by(Vector[ 1, -1])
      when "n" then move_by(Vector[ 1,  1])

      when "g" 
        player_entity.card_state.action= :draw
      when "f"
        check_hand(:weapon)
        player_entity.card_state.action= :weapon
      when "d"
        check_hand(:spell)
        player_entity.card_state.action= :spell
      when "s"
        check_hand(:item)
        player_entity.card_state.action= :use_item
      when "a"
        check_hand(:item)
        player_entity.card_state.action= :replace_item
      end
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
