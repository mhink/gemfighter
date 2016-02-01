module Components
  InputReceiver = Component.with(:input)

  class InputReceiver
    attr_writer :input
  end

  HasMessages = Component.with(:messages)
  HasSize = Component.with(:size)
  HasWindow = Component.with(:window)

  class HasWindow
    def window=(window)
      if @window.nil?
        @window = window
      else
        raise "HasWindow#window may only be set once!"
      end
    end
  end
end
