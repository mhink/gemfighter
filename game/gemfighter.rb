require 'game'

require 'control_system'
require 'player_system'
require 'map_system'
require 'card_system'
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

    DrawingSystem.init!
    AiSystem.init!
    MapSystem.init!
  end

  def start
    @window.on_input = Proc.new do
      Entity.find("input").input = @window.active_input

      catch(:next_input) do
        ControlSystem.handle_game_input!
        PlayerSystem.handle_player_input!
        AiSystem.run_ai!
        CardSystem.update_decks!
        MapSystem.check_entity_movement!
        LogSystem.write_messages_to_log!
      end

      DrawingSystem.prepare_drawables!
    end

    @window.on_update = Proc.new do
      DrawingSystem.next_frame!
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
      sword = Entity.new(
        card_type: :weapon,
        description: "a sword",
        cooldown: 3,
        cooldown_timer: -1
      )

      magic_missile = Entity.new(
        card_type: :spell,
        description: "magic missile",
        contamination: 3,
      )

      cstate = Entity.new("player_card_state",
        is_card_state:  true,
        contaminated:   false,
        action:         nil,
        weapon:         sword,
        spell:          magic_missile,
        item:           nil,
        deck: [])

      Entity.new("player",
        card_state:   cstate,
        layer_name:   'actors',
        position:     Point[1,1],
        movement:     nil,
        tile_index:   0)

      Entity.new("scroll",
        card_type:    :item,
        description:  "a scroll with weird-looking symbols",
        layer_name:   'items',
        position:     Point[1,2],
        tile_index:   5)

      Entity.new("scroll2",
        card_type:    :item,
        description:  "a scroll with funny-looking symbols",
        layer_name:   'items',
        position:     Point[1,3],
        tile_index:   5)

      Entity.new("walls",
        draw_with:  :draw_walls,
        grid_size:  Size[32,32],
        bitmap:     Bitmap[MAP_SIZE].from_s(WALLS))

      Entity.new("actors",
        draw_with:  :draw_actors,
        map_with:   :update_actors,
        grid_size:  Size[32,32],
        bitmap:     Bitmap[MAP_SIZE])

      Entity.new("items",
        draw_with:  :draw_items,
        grid_size:  Size[32,32],
        bitmap:     Bitmap[MAP_SIZE])

      Entity.new("input", input: nil)
    end
end
