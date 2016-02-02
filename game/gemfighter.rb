require 'game'

require 'shutdown_system'
require 'window_system'
require 'input_system'
require 'log_system'

include Geometry

class Gemfighter < Game
  def initialize
    super

    Entity.new(input: nil, shutdown: true)
    Entity.new(input: nil, messages: [])
    Entity.new(size: Size[800, 600], window: nil)

    @input_system    = InputSystem.new
    @shutdown_system = ShutdownSystem.new
    @log_system      = LogSystem.new
    @window_system   = WindowSystem.new do |window|
      window.on_update do |input|
        @input_system.run!
        @log_system.run!
        @shutdown_system.run!
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
