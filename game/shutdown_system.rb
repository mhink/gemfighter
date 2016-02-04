module ShutdownSystem
  class << self
    def run!
      case input_entity.input
      when "q" then throw(:game_end)
      when "d" then Entity.dump_debug!
      end
    end

    private
      def input_entity
        Entity.find("input")
      end
  end
end
