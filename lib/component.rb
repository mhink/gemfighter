class Component
  attr_reader :entity

  def self.with(*attributes)
    Class.new(Component) do
      attributes.each do |attr|
        attr_reader attr
      end

      define_method(:initialize) do |entity, **kwargs|
        (kwargs.keys & attributes).each do |attr|
          self.instance_variable_set("@#{attr}", kwargs[attr])
        end
        super(entity)
      end
    end
  end

  def initialize(entity)
    @entity = entity
  end
end
