module InputSystem
  class << self

  def init!
    Entity.new("input", 
               input: nil)
  end

  def handle_input!
    input = window_entity.window.active_input

    input_entities.each do |entity|
      entity.input = input
    end
  end

  private
    def window_entity
      Entity.find("window")
    end

    def input_entities
      Entity.find_by(:@input)
    end
  end
end
