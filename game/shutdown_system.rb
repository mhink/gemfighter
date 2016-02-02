class ShutdownSystem
  def run!
    if shutdown_entity.input == "q"
      throw(:game_end)
    end
  end

  private
    def shutdown_entity
      Entity.instances_with(:@input).first
    end
end
