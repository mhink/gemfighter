require 'system'

class InputSystem < System
  attr_reader :handler

  def receive(input)
    receiver_entity.input_receiver.input= input
  end

  def run!
    ent = receiver_messages_entity
    input_receiver, has_messages= ent.input_receiver, ent.has_messages
    input, messages = input_receiver.input, has_messages.messages

    case input
    when nil then return
    when "q" then throw(:game_end)
    else
      messages << "Got #{input}"
    end
  end

  private
    def receiver_entity
      registry.find(InputReceiver).first
    end

    def receiver_messages_entity
      registry.find(InputReceiver, HasMessages).first
    end
end
