require 'set'

class Entity
  attr_reader :components

  def self.create(registry, *component_types, **kwargs)
    new(*component_types, **kwargs).tap do |entity|
      registry.register(entity)
    end
  end

  private_class_method :new
  def initialize(*component_types, **kwargs)
    @components = Hash.new

    component_types.each do |klass|
      @components[klass] = klass.new(self, **kwargs)
    end
  end
end

def Entity(*component_types)
  Class.new(Entity) do
    self.singleton_class.class_eval do
      define_method(:create) do |registry, **kwargs|
        super(registry, *component_types, **kwargs)
      end
    end
  end
end
