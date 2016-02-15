module ControlSystem
  class << self
    def handle_game_input!
      case input_entity.input
      when "q" then throw(:game_end)
      when "w" then spawn_scroll
      when "e" then spawn_rat
      when "r" then Entity.dump_debug!
      end
    end

    private
      def save_and_quit
      end

      def spawn_scroll
        player = Entity.find("player")
        walls  = Entity.find("walls")
        actors = Entity.find("actors")
        items  = Entity.find("items")

        pos = player.position + Point[0,1]

        return unless walls.bitmap.in_bounds?(pos)

        wocc = walls.bitmap[pos]
        aocc = actors.bitmap[pos]
        iocc = items.bitmap[pos]

        return if (wocc || aocc || iocc)

        Entity.new(
          layer_name: 'items',
          position: pos,
          tile_index: 5)
        items.bitmap.set(pos)
        throw :next_input
      end

      def spawn_rat
        prng = Random.new

        walls  = Entity.find("walls")
        actors = Entity.find("actors")

        cbm = (walls.bitmap | actors.bitmap)

        open_set = []
        cbm.each do |b, x, y, ix|
          unless b
            open_set << Point[x, y]
          end
        end

        pos = open_set[prng.rand(open_set.length)]

        new_rat = Entity.new(
          layer_name:   'actors',
          position:     pos,
          movement:     nil,
          tile_index:   1,
          ai_method:    :rat_ai)

        actors.bitmap[pos]= true
        throw :next_input
      end

      def input_entity
        Entity.find("input")
      end
  end
end
