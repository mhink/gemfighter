require 'game'

require 'input_system'
require 'log_system'
require 'components'
include Components

Player = Entity(InputReceiver, HasMessages)

class Gemfighter < Game
  def initialize
    super

    @input_system = InputSystem.new(registry)
    @log_system = LogSystem.new(registry)
    systems = []
    systems << @input_system
    systems << @log_system

    Player.create(registry, messages: [])
  end

  protected
    def receive(input)
      @input_system.receive(input)
    end

    def update
      @input_system.run!
      @log_system.run!
      true
    end

    def draw
    end
end
