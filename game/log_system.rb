class LogSystem
  def run!
    message_entities.each do |ent|
      ent.messages.each do |msg|
        puts msg
      end
      ent.messages.clear
    end
  end

  private
    def message_entities
      Entity.find_all do |entity|
        entity.instance_variable_defined?(:@messages)
      end
    end
end
