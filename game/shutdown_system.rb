module ShutdownSystem
  class << self
    def check_for_game_actions!
      case input_entity.input
      when "q" then throw(:game_end)
      when "d" then Entity.dump_debug!
      when "f" then spawn_rat
      end
    end

    private
      def spawn_rat
        prng = Random.new

        map = Entity.find("map")

        cbm = (map.entity_bitmap | map.wall_bitmap)

        open_set = []
        cbm.each do |b, x, y, ix|
          unless b
            open_set << Point[x, y]
          end
        end

        pos = open_set[prng.rand(open_set.length)]

        new_rat = Entity.new(
          position:     pos,
          movement:     nil,
          tile_index:   1,
          ai_method:    :rat_ai,
        )

        map.entity_children << new_rat
      end

      def input_entity
        Entity.find("input")
      end
  end
end
