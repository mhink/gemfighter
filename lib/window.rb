require 'gosu'

class Window < Gosu::Window
  DELAY_UNTIL_KEY_REPEAT = 500 #ms
  KEY_REPEAT_INTERVAL    = 70  #ms

  attr_writer :on_input, :on_update, :on_draw

  def initialize(size: Size[16,16])
    super(*size.to_a)
    self.caption= "Gemfighter"

    @needs_redraw = true
    reset_keypress

    @on_input  = -> {}
    @on_update = -> {}
    @on_draw   = -> {}
  end

  def active_input
    button_id_to_char(@active_key)
  end

  def button_down(id)
    set_keypress(id)
    catch(:next_input) do
      @on_input.call
    end
  end

  def button_up(id)
    reset_keypress if (id == @active_key)
  end

  def update
    (@needs_redraw = true) if @on_update.call

    if @active_key.nil?
      return
    end

    if @delay_elapsed > 0
      @delay_elapsed -= update_interval
      return
    end

    if @interval_elapsed > 0
      @interval_elapsed -= update_interval
      return
    end

    @interval_elapsed += KEY_REPEAT_INTERVAL
    catch(:next_input) do
      @on_input.call
    end
  end

  def needs_redraw?
    @needs_redraw
  end

  def draw
    @on_draw.call
    @needs_redraw = false
  end

  private
    def request_redraw!
      @needs_redraw = true
    end

    def set_keypress(id)
      @active_key       = id
      @delay_elapsed    = DELAY_UNTIL_KEY_REPEAT
      @interval_elapsed = KEY_REPEAT_INTERVAL 
    end

    def reset_keypress
      set_keypress(nil)
    end
end
