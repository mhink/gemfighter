require 'bitmap'

module MapSystem
  class << self
    def init!
      actors = entities_for_layer(actors_layer)
      items  = entities_for_layer(items_layer)

      actors.each do |actor|
        actors_layer.bitmap[actor.position]= true
      end

      items.each do |item|
        items_layer.bitmap[item.position]= true
      end
    end

    def clear_movement!
      movables = Entity.find_by(:@movement).each do |entity|
        entity.movement= nil
      end
    end

    def update_map_indexes!
      maps = Entity.find_by(:@indexed_positions).each do |map|
        removed      = []
        non_matching = Hash.new{|h,k|h[k]=[]}

        map.indexed_positions.each_pair do |pos, entities|
          entities.delete_if do |entity|
            entity.map_name != map.name
          end

          entities.each do |entity|
            if entity.position != pos
              non_matching[pos] << entity
            end
          end
        end

        non_matching.each do |pos, entities|
          entities.each do |entity|
            map[pos].delete(entity)
            map[entity.position].push(entity)
          end
        end
      end
    end

    def move_entities!
      Entity.find_by(:@map_name).each do |entity|
        next unless entity.has?(:@movement)

        oldpos = entity.position
      end

      actors.each do |actor|
        oldpos = actor.position

        if actor.movement.nil?
          actors_layer.bitmap[oldpos]= true
        end

        newpos = actor.position + actor.movement

        ebm = actors_layer.bitmap
        wbm = walls_layer.bitmap
        ibm = items_layer.bitmap

        unless ebm.in_bounds?(newpos)
          actor.movement = nil
          next
        end

        if wbm[newpos]
          actor.movement = nil
          next
        end

        if ibm[newpos]
          item = entities_for_layer(items_layer).find do |item|
            item.position == newpos
          end

          if actor.has?(:@card_state)
            if item.has?(:@description)
              STDERR.puts "Picked up #{item.description}."
            else
              STDERR.puts "Picked up an item."
            end

            ibm[newpos]= false
            actor.card_state.deck << item
            item.clear :@layer_name
            item.clear :@position
          end
        end

        ebm[oldpos]= false
        ebm[newpos]= true
        actor.position += actor.movement
      end
    end

    private
    def entities_for_map(map)
      Entity.find_by(:@map_name).select do |entity|
        entity.map_name == map.name
      end
    end
  end
end
