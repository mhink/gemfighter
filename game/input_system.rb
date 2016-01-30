class InputSystem
  attr_reader :handler

  def initialize(registry)
    @registry = registry
  end

  def receive(input)
    receiver_component.input= input
  end

  def run!
    input_comp, msg_comp = receiver_message_components
    input, messages = input_comp.input, msg_comp.messages

    case input
    when nil then return
    when "q" then throw(:game_end)
    else
      messages << "Got #{input}"
    end
  end

  private
    def receiver_component
      @registry.find_components(InputReceiver).first.values.first
    end

    def receiver_message_components
      @registry.find_components(InputReceiver, HasMessages).first.values
    end
end
