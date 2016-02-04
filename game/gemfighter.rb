require 'game'

require 'shutdown_system'
require 'window_system'
require 'input_system'
require 'player_system'
require 'map_system'
require 'movement_system'
require 'log_system'

include Geometry

class Gemfighter < Game
  def initialize
    super

    WindowSystem.on_update do
      InputSystem.run!
      PlayerSystem.run!
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
      InputSystem.init!
      PlayerSystem.init!
      WindowSystem.start
    end

    def stop
      WindowSystem.stop
    end
end
