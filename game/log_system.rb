class LogSystem < System
  def run!
    message_components.each do |(message_comp)|
      message_comp.messages.each do |msg|
        puts msg
      end
      message_comp.messages.clear
    end
  end

  private
    def message_components
      registry.find_components(HasMessages).map(&:values)
    end
end
