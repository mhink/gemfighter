require 'bitmap'

module MapSystem
  class << self
    def init!
      actors_layer = Entity.find("actors")
      items_layer  = Entity.find("items")
      actors = entities_for_layer(actors_layer)
      items  = entities_for_layer(items_layer)

      actors.each do |actor|
        actors_layer.bitmap[actor.position]= true
      end

      items.each do |item|
        items_layer.bitmap[item.position]= true
      end
    end

    def check_entity_movement!
      Entity.find_by(:@map_with).each do |layer|
        self.send(layer.map_with, layer)
      end
    end

    def update_actors(actors_layer)
      walls_layer = Entity.find("walls")
      items_layer = Entity.find("items")
      actors = entities_for_layer(actors_layer)

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

          if actor.has?(:@inventory)
            puts "Snagged an item!"
            ibm[newpos]= false
            actor.inventory << item
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
    def entities_for_layer(layer)
      Entity.find_by(:@layer_name).select do |entity|
        entity.layer_name == layer.name
      end
    end
  end
end
