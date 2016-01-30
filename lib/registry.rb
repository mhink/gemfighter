require 'set'

class Registry
  def initialize
    @register = Hash.new { |h, k| h[k] = Set.new }
  end

  def register(entity)
    entity.components.each do |klass, _|
      @register[klass] << entity
    end
  end

  def all
    union(@register.values)
  end

  def find(*components)
    lists = components.map do |component|
      @register[component]
    end

    intersect(lists)
  end

  def find_components(*components)
    self.find(*components).map do |entity|
      entity.components.select do |klass, component|
        components.include? klass
      end
    end
  end

  private
  def intersect(list_of_lists)
    list_of_lists.inject(list_of_lists.first, &:intersection)
  end

  def union(list_of_lists)
    list_of_lists.inject([], &:union)
  end
end
