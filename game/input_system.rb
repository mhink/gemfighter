module InputSystem
  class << self
  def run!
    input = window_entity.window.active_input

    input_entities.each do |entity|
      entity.input = input
    end
  end

  private
    def window_entity
      Entity.instances_with(:@window).first
    end

    def input_entities
      Entity.instances_with(:@input)
    end
  end
end
