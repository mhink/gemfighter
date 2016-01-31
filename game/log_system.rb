class LogSystem < System
  def run!
    message_entities.each do |ent|
      ent.has_messages.messages.each do |msg|
        puts msg
      end
      ent.has_messages.messages.clear
    end
  end

  private
    def message_entities
      registry.find(HasMessages)
    end
end
