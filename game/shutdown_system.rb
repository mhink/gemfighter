class ShutdownSystem
  def run!
    if shutdown_entity.input == "q"
      throw(:game_end)
    end
  end

  private
    def shutdown_entity
      entities = Entity.instances_with(:@input, :@shutdown)
      validate(entities)
      entities.first
    end

    def validate(entities)
      if entities.length > 1
        raise "There should not be more than one Entity with @input/@shutdown"
      end

      if entities.length < 1
        raise "Cannot find a @input/@shutdown Entity!"
      end
    end
end
