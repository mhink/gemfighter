module AiSystem
  class << self
    def init!
      @prng = Random.new
    end

    def run_ai!
      Entity.find_by(:@ai_method).each do |entity|
        entity.movement= nil if entity.has? :movement
        self.send(entity.ai_method.to_sym, entity)
      end
    end

    private
      def rat_ai(entity)
        case @prng.rand(8)
        when 0 then move_by(entity, Vector[-1,0])
        when 1 then move_by(entity, Vector[0,1])
        when 2 then move_by(entity, Vector[0,-1])
        when 3 then move_by(entity, Vector[1,0])
        when 4 then move_by(entity, Vector[-1, -1])
        when 5 then move_by(entity, Vector[-1,  1])
        when 6 then move_by(entity, Vector[ 1, -1])
        when 7 then move_by(entity, Vector[ 1,  1])
        end
      end

      def move_by(entity, vector)
        entity.movement= vector
      end
  end
end
