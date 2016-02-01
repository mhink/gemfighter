require 'window'
require 'system'

class WindowSystem < System
  def initialize(registry, &block)
    super(registry)
    @setup_callback= block
  end

  def start(&block)
    window = Window.new(size: window_entity.has_size.size)
    window_entity.has_window.window= window
    @setup_callback.try(:call, window)
    window.show
  end

  def run!
  end

  def stop
    window_entity.has_window.window.close
  end

  private
    def window_entity
      registry.find(HasSize, HasWindow).first
    end
end
