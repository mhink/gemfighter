require 'window'
require 'system'

class WindowSystem < System
  def initialize(registry, &block)
    super(registry)
    @setup_callback= block
  end

  def start(&block)
    window = Window.new(size: size_component.size)
    window_component.window= window
    @setup_callback.try(:call, window)
    window.show
  end

  def run!
  end

  def stop
    window_component.window.close
  end

  private
    def size_component
      window_entity.components[HasSize]
    end

    def window_component
      window_entity.components[HasWindow]
    end

    def window_entity
      registry.find(HasSize, HasWindow).first
    end
end
