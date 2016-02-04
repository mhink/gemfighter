require 'pp'

class Entity < Object
  class << self
    include Enumerable

    def dump_debug!
      named_instances.each do |name, entity|
        STDERR.puts "#{name} => #{entity.to_s}"
      end

      instances.each do |entity|
        PP.pp(entity, STDERR)
      end
      STDERR.puts "---"
    end

    def find_by(*ivars_we_want)
      # TODO: accept a looser syntax from args

      instances.find_all do |instance|
        defined_ivar_set    = Set.new(instance.instance_variables)
        requested_ivar_set  = Set.new(ivars_we_want)

        requested_ivar_set <= defined_ivar_set
      end
    end

    def find(name)
      named_instances[name]
    end

    def each(&block)
      instances.each(&block)
    end

    def register(name=nil, entity)
      if name
        if named_instances.has_key? name
          raise "Cannot create an Entity with duplicate name!"
        else
          named_instances[name]= entity
        end
      end

      instances << entity
    end

    private
      def named_instances
        @named_instances ||= Hash.new
      end

      def instances
        @instances ||= Set.new
      end
  end

  def initialize(name=nil, **kwargs)
    kwargs.each do |k, v| 
      self.instance_variable_set("@#{k}", v)
    end

    Entity.register(name, self)
  end

  def method_missing(method_name, *args, **kwargs, &block)
    is_setter = method_name.to_s.end_with? "="
    ivar_name = "@" + method_name.to_s.match(/([^=]*)=?/)[1]

    if instance_variable_defined?(ivar_name)
      if is_setter
        instance_variable_set(ivar_name, args[0])
      else
        instance_variable_get(ivar_name)
      end
    else
      super
    end
  rescue Exception => ex
    raise ex
  end

  # Lock it down
  def self.method_added(mname)
    raise "Do *not* add methods to Entity!"
  end
end
