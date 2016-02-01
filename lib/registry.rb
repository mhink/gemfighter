require 'set'

# This class is sort of a database for Entities. Anything with a handle
# to a Registry can query it for Entities which are composed of certain
# components. This allows a System to be almost completely decoupled from
# the logic for managing entity lifecycles.
#
# Considering that this is basically a simple, in-memory database, future
# development will likely involve storing Entities in an actual database-
# likely SQLite.

class Registry
  def initialize
    @register = Hash.new { |h, k| h[k] = Set.new }
  end

  def register(entity)
    entity.components.each do |component|
      @register[component.class] << entity
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
      entity.components.select do |component|
        components.include?(component.class)
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
