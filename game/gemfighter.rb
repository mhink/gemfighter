require 'game'

require 'shutdown_system'
require 'window_system'
require 'input_system'
require 'movement_input_system'
require 'map_system'
require 'movement_system'
require 'log_system'

include Geometry

class Gemfighter < Game
  def initialize
    super

    # A little proto-player entity.
    Entity.new(visible:    true,
               tile_index: 0,
               scale: Vector[2,2],
               movement:   nil,
               position:   Point[1,1])

    InputSystem.init!

    WindowSystem.on_update do
      InputSystem.run!
      MovementInputSystem.run!
      MapSystem.run!
      MovementSystem.run!
      LogSystem.run!
      ShutdownSystem.run!
      true
    end

    WindowSystem.on_draw do
      WindowSystem.run!
    end
  end

  protected
    def start
      WindowSystem.start
    end

    def stop
      WindowSystem.stop
    end
end
