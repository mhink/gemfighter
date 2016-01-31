require 'set'
require 'active_support/core_ext'

class Entity
  extend Forwardable

  attr_reader :components

  def self.component_types
    []
  end

  def self.create(registry, **kwargs)
    new(**kwargs).tap do |entity|
      registry.register(entity)
    end
  end

  private_class_method :new
  def initialize(**kwargs)
    @components = []
    self.class.component_types.each do |klass|
      component = klass.new(self, **kwargs)
      @components << component
      self.instance_variable_set("@#{klass.name.demodulize.underscore}", component)
    end
  end
end

def Entity(*component_types)
  Class.new(Entity) do
    component_types.each do |klass|
      attr_reader(klass.name.demodulize.underscore)
    end

    self.singleton_class.class_eval do
      define_method(:component_types) do
        component_types
      end
    end
  end
end
