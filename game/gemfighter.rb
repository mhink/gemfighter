require 'game'

require 'shutdown_system'
require 'player_system'
require 'map_system'
require 'log_system'
require 'drawing_system'
require 'ai_system'

class Gemfighter < Game
  def initialize
    super
    init_tiles!

    @window = Window.new(size: Size[800,600])

    Entity.new("input", input: nil)
    Entity.new("player")
    Entity.new("map")
    Entity.new("render_root")

  end

  def start
    MapSystem.init!
    PlayerSystem.init!
    DrawingSystem.init!
    AiSystem.init!

    rat = Entity.new(
      position: Point[8,8],
      movement: nil,
      tile_index: 1,
      ai_method: :rat_ai,
    )

    Entity.find("map").entity_children << rat

    @window.on_update do
      Entity.find("input").input = @window.active_input

      PlayerSystem.move_player!
      AiSystem.run_ai!
      MapSystem.check_entity_movement!
      LogSystem.write_messages_to_log!
      ShutdownSystem.check_for_game_actions!
      true
    end

    @window.on_draw do
      DrawingSystem.draw!
    end

    @window.show
  end

  def stop
    @window.close
  end

  private
  def init_tiles!
    tiles = Gosu::Image.load_tiles(
        RES_DIR.join("tiled-icons-16x16.png").to_s, 
        16, 16,
        retro: true)

    tiles.each_with_index do |img, ix|
      # Create an Entity for each tile
      Entity.new(tile_index: ix, 
                 tile_image: img,
                 scale:      Vector[2,2])
    end
  end
end
