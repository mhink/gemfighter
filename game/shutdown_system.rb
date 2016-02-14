module ShutdownSystem
  class << self
    def check_for_game_actions!
      case input_entity.input
      when "s" then spawn_scroll
      when "q" then throw(:game_end)
      when "d" then Entity.dump_debug!
      when "f" then spawn_rat
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
      end

      def input_entity
        Entity.find("input")
      end
  end
end
