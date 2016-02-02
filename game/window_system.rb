require 'window'

class WindowSystem
  def initialize(&block)
    @setup_callback= block
  end

  def start
    wnd = Window.new(size: window_entity.size)
    window_entity.window = wnd
    @setup_callback.try(:call, wnd)
    wnd.show
  end

  # Perhaps #run! isn't as great for these methods, since
  # we need to distinguish between 'stuff that happens during
  # update' and 'stuff that happens during rendering'.
  #
  # The question is, should this be a system-level distinction
  # or a method-level distinction?
  def run!
    on_tile = tile_entities[0].tile

    position_entities.each do |entity|
      x, y = entity.position.to_a
      on_tile.draw(entity.position.x * 16, entity.position.y * 16, 0)
    end
  end

  def stop
    window_entity.window.close
  end

  private
    def tile_entities
      Entity.instances_with(:@index, :@tile)
    end

    def window_entity
      Entity.instances_with(:@size, :@window).first
    end

    def position_entities
      Entity.instances_with(:@position)
    end
end
