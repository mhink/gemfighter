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

    puts "Initializing entities..."
    Gosu::Image.load_tiles(RES_DIR.join("onoff-16.png").to_s, 16, 16).each_with_index do |img, ix|
      # Create an Entity for each tile
      Entity.new(tile_index: ix, 
                 tile_image: img)
    end

    # The input channel!
    Entity.new(input: nil)

    # A little proto-player entity.
    Entity.new(visible:    true,
               tile_index: 0,
               movement:   nil,
               position:   Point[1,1])

    # The window itself
    Entity.new(window:     nil,
               grid_size:  Size[16,16],
               size:       Size[800, 600], 
               size_tiles: Size[50, 37])

    puts "Initializing systems..."
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
