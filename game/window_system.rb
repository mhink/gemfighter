require 'window'

module WindowSystem
  class << self
    def on_update(&block)
      @on_update_callback = block
    end

    def on_draw(&block)
      @on_draw_callback = block
    end

    def start
      window_size = Size[800, 600]
      window = Window.new(size: window_size)
      window.on_update(&@on_update_callback)
      window.on_draw(&@on_draw_callback)

      Entity.new("window",
                 window:     window,
                 size:       window_size, 
                 grid_size:  Size[32,32],
                 size_tiles: Size[25,18])
      window.show
    end

    def stop
      Entity.find("window").window.close
    end
  end
end
