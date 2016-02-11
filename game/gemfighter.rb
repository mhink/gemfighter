require 'game'

require 'shutdown_system'
require 'player_system'
require 'map_system'
require 'log_system'
require 'drawing_system'
require 'ai_system'

class Gemfighter < Game
  WALLS = "1111111111111111111111111100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000100000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011111111111111111111111111"
  MAP_SIZE= Size[25,19]

  def initialize(save_file=nil)
    super()

    @window = Window.new(size: Size[800,600])

    if save_file
      load_from_save! save_file
    else
      load_from_nothing!
    end
  end

  def start
    DrawingSystem.init!
    AiSystem.init!

    @window.on_input = Proc.new do
      Entity.find("input").input = @window.active_input

      PlayerSystem.move_player!
      AiSystem.run_ai!
      MapSystem.check_entity_movement!
      LogSystem.write_messages_to_log!
      ShutdownSystem.check_for_game_actions!
      DrawingSystem.prepare_tweens!
    end

    @window.on_update = Proc.new do
      DrawingSystem.update_tweens!
      true
    end

    @window.on_draw = Proc.new do
      DrawingSystem.draw!
    end

    @window.show
  end

  def stop
    @window.close
  end

  private
    def load_from_save!(save_filename)
      Entity.load(save_filename)
    end

    def load_from_nothing!
      player = Entity.new("player",
        position: Point[1,1],
        movement: nil,
        tile_index: 0)

      rat = Entity.new(
        position:     Point[9,9],
        movement:     nil,
        tile_index:   1,
        ai_method:    :rat_ai)

      Entity.new("map",
        size:            MAP_SIZE,
        entity_bitmap:   Bitmap[MAP_SIZE],
        wall_bitmap:     Bitmap[MAP_SIZE].from_s(WALLS),
        entity_children: [player, rat],
        grid_size:       Size[32,32],
        render_with:     :draw_map)

      Entity.new("input", input: nil)
    end
end
