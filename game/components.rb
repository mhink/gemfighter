module Components
  InputReceiver = Component.with(:input)

  class InputReceiver
    attr_writer :input
  end

  HasMessages = Component.with(:messages)
  HasSize = Component.with(:size)
  HasWindow = Component.with(:window)
end
