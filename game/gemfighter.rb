require 'game'

require 'window_system'
require 'input_system'
require 'log_system'
require 'components'

include Geometry
include Components

WindowEntity = Entity(HasSize, HasWindow)
PlayerEntity = Entity(InputReceiver, HasMessages)

class Gemfighter < Game
  def initialize
    super

    WindowEntity.create(registry, size: Size[800,600], window: nil)
    PlayerEntity.create(registry, messages: [])

    @window_system = WindowSystem.new(registry) do |window|
      window.on_update do |input|
        @input_system.receive(input)
        @input_system.run!
        @log_system.run!
        true
      end
    end

    @input_system = InputSystem.new(registry)
    @log_system = LogSystem.new(registry)
  end

  protected
    def start
      @window_system.start
    end

    def shutdown
      @window_system.stop
    end
end
