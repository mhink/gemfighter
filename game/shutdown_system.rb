module ShutdownSystem
  class << self
    def run!
      if input_entity.input == "q"
        throw(:game_end)
      end
    end

    private
      def input_entity
        Entity.find("input")
      end
  end
end
