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

    tiles = Gosu::Image.load_tiles(
        RES_DIR.join("tiled-icons-16x16.png").to_s, 
        16, 16,
        retro: true).zip([:guy, :rat, :wall, :sign, :meat])

    tiles.each_with_index do |(img, name), ix|
      # Create an Entity for each tile
      Entity.new(tile_index: ix, 
                 tile_image: img,
                 tile_name: name)
    end

    # The input channel!
    Entity.new(input: nil)

    # A little proto-player entity.
    Entity.new(visible:    true,
               tile_index: 0,
               scale: Vector[2,2],
               movement:   nil,
               position:   Point[1,1])

    # The window itself
    Entity.new(window:     nil,
               grid_size:  Size[32,32],
               size:       Size[800,600], 
               size_tiles: Size[25,18])

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
