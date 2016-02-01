require 'game'

require 'components'
require 'window_system'
require 'input_system'
require 'log_system'

include Components
include Geometry

WindowEntity = Entity(HasSize, HasWindow)
PlayerEntity = Entity(InputReceiver, HasMessages)

class Gemfighter < Game
  def registry
    @registry ||= Registry.new
  end

  def initialize
    super

    WindowEntity.create(registry, size: Size[800,600], window: nil)
    PlayerEntity.create(registry, messages: [])

    @input_system  = InputSystem.new(registry)
    @log_system    = LogSystem.new(registry)
    @window_system = WindowSystem.new(registry) do |window|
      window.on_update do |input|
        @input_system.receive(input)
        @input_system.run!
        @log_system.run!
        true
      end
    end
  end

  protected
    def start
      @window_system.start
    end

    def stop
      @window_system.stop
    end
end
