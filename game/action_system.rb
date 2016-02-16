module ActionSystem
  class << self
    def perform_actions!
      Entity.find_by(:@evoke_as).each do |evocation|
        self.send(evocation.evoke_as, evocation)
        Entity.destroy(evocation)
      end
    end

    private
      def magic_missile(evocation)
        puts "You cast Magic Missile!"
      end
  end
end
