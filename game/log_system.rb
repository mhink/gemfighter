class LogSystem
  attr_writer :input

  def initialize(registry)
    @registry = registry
  end

  def run!
    @registry.find(HasMessages).each do |entity|
      messages = entity.components[HasMessages].messages
      messages.each do |msg|
        puts msg
      end
      messages.clear
    end
  end
end
