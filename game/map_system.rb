class MapSystem
  def run!
  end

  private
    def map_entities
      Entity.instances_with(:@map)
    end

    def mapped_entities
      Entity.instances_with(:@position)
    end
end
