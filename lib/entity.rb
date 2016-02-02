class Entity < Object
  class << self
    include Enumerable

    def instances_with(*ivars_we_want)
      # TODO: accept a looser syntax from args

      instances.find_all do |instance|
        defined_ivar_set    = Set.new(instance.instance_variables)
        requested_ivar_set  = Set.new(ivars_we_want)

        requested_ivar_set <= defined_ivar_set
      end
    end

    def each(&block)
      instances.each(&block)
    end

    private
      def instances
        @instances ||= Set.new
      end
  end

  def initialize(**kwargs)
    kwargs.each do |k, v| 
      self.instance_variable_set("@#{k}", v)
    end

    Entity.send(:instances) << self
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
    binding.pry
    raise ex
  end

  # Lock it down
  def self.method_added(mname)
    raise "Do *not* add methods to Entity!"
  end
end
