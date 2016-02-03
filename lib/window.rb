require 'gosu'

class Window < Gosu::Window
  DELAY = 500 # ms
  KEY_INTERVAL = 70 #ms

  attr_reader :active_key

  def active_input
    button_id_to_char(@active_key)
  end

  def initialize(size: Size[16,16])
    super(*size.to_a)
    self.caption= "Gemfighter"
    @needs_redraw = true
    @active_key = nil
  end

  def on_update(&block)
    @update_callback = block
  end

  def on_draw(&block)
    @draw_callback = block
  end

  def update
    unless @active_key.nil?
      if @delay_elapsed < DELAY
        @delay_elapsed += update_interval
      else
        if @interval_elapsed >= KEY_INTERVAL
          @interval_elapsed -= KEY_INTERVAL
          run_game!
        else
          @interval_elapsed += update_interval
        end
      end
    end
  end

  def button_down(id)
    @active_key = id
    @delay_elapsed = 0
    @interval_elapsed = KEY_INTERVAL
    run_game!
  end

  def run_game!
    scene_result = @update_callback.try(:call)
    @needs_redraw = (scene_result ? true : false)
  end

  def button_up(id)
    if (id == @active_key)
      @active_key = nil
    end
  end

  def needs_redraw?
    @needs_redraw
  end

  def draw
    @draw_callback.try(:call)
    @needs_redraw = false
  end
end
