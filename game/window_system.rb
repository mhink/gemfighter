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

  def run!
  end

  def stop
    window_entity.window.close
  end

  private
    def window_entity
      entities = Entity.find_all do |entity|
        entity.instance_variable_defined?(:@size) &&
        entity.instance_variable_defined?(:@window)
      end

      if(entities.length > 1)
        raise "Found more than one entity with @window!"
      elsif(entities.length < 1)
        raise "Did not find any entities with @window!"
      else
        entities.first
      end
    end
end
