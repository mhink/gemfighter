require 'game'

require 'shutdown_system'
require 'window_system'
require 'input_system'
require 'movement_input_system'
require 'movement_system'
require 'log_system'

include Geometry

class Gemfighter < Game
  def initialize
    super

    puts "Initializing entities..."
    Gosu::Image.load_tiles(RES_DIR.join("onoff-16.png").to_s, 16, 16).each_with_index do |img, ix|
      # Create an Entity for each tile
      Entity.new(index: ix, tile: img)
    end

    # The input channel!
    Entity.new(input: nil)

    # A little proto-player entity.
    Entity.new(movement: nil,
               position: Point[1,1])

    # The window itself
    Entity.new(window:     nil,
               grid_size:  Size[16,16],
               size:       Size[800, 600], 
               size_tiles: Size[50, 37])

    puts "Initializing systems..."
    @input_system    = InputSystem.new
    @movement_input_system = MovementInputSystem.new
    @movement_system = MovementSystem.new
    @log_system      = LogSystem.new
    @shutdown_system = ShutdownSystem.new

    @window_system   = WindowSystem.new do |window|
      window.on_update do |input|
        @input_system.run!
        @movement_input_system.run!
        @movement_system.run!
        @log_system.run!
        @shutdown_system.run!
        true
      end

      window.on_draw do
        @window_system.run!
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
