class System
  def initialize(registry)
    @registry = registry
  end

  def run!
    raise "Implement in System subclass!"
  end

  protected
    attr_reader :registry
end
