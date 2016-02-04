module LogSystem
  class << self
  def write_messages_to_log!
    message_entities.each do |ent|
      ent.messages.each do |msg|
        # puts msg
      end
      ent.messages.clear
    end
  end

  private
    def message_entities
      Entity.find_by(:@messages)
    end
  end
end
