require 'game'

require 'shutdown_system'
require 'window_system'
require 'input_system'
require 'player_system'
require 'map_system'
require 'log_system'
require 'drawing_system'

include Geometry

class Gemfighter < Game
  def initialize
    super
    Entity.new("player")
  end

  def start
    WindowSystem.init!
    DrawingSystem.init!
    InputSystem.init!
    MapSystem.init!

    WindowSystem.on_update do
      InputSystem.handle_input!
      PlayerSystem.move_player!
      MapSystem.check_entity_movement!
      LogSystem.write_messages_to_log!
      ShutdownSystem.check_for_game_actions!
      true
    end

    WindowSystem.on_draw do
      DrawingSystem.draw!
    end

    WindowSystem.start
  end

  def stop
    WindowSystem.stop
  end
end
