require 'game'

require 'shutdown_system'
require 'player_system'
require 'map_system'
require 'log_system'
require 'drawing_system'

include Geometry

WALLS = "1111111111111111111111111100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000100000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011111111111111111111111111"

class Gemfighter < Game
  def initialize
    super
    init_tiles!

    @window = Window.new(size: Size[800,600])

    Entity.new("input", 
      input: nil)

    player = Entity.new("player",
      tile_index: 0,
      position: Point[1,1],
      movement: nil,
      render_with: :draw_map_entity)

    walls = Entity.new(
      tile_index:  2,
      bitmap:      Bitmap[25,19].from_s(WALLS),
      render_with: :draw_bitmap)

    map = Entity.new("map",
      size:             Size[25,19],
      grid_size:        Size[32,32],
      wall_tile_index:  2,
      bitmap:           Bitmap[25,19],
      entity_children:  [player],
      bitmap_children:  [walls],
      render_with:      :draw_map,
      render_children:  [walls, player])

    Entity.new("render_root",
      render_children: [map])
  end

  def start
    MapSystem.init!

    @window.on_update do
      Entity.find("input").input = @window.active_input

      PlayerSystem.move_player!
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
