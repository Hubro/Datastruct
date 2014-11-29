
##
# A factory method for DataStruct subclasses
#
def DataStruct(*props, &block)
  Class.new(DataStruct) { |cls|
    cls.const_set(:PROPERTIES, props)

    class_exec(&block) unless block.nil?
  }
end

class DataStruct
  VERSION = "0.0.1"

  ##
  # A more ideomatic way of calling +new(*array)+
  #
  def self.from_array(array)
    self.new(*array)
  end

  ##
  # A more ideomatic way of calling +new(**hash)+
  #
  def self.from_hash(hash)
    self.new(**hash)
  end

  def initialize(*args, **kwargs)
    @data ||= {}

    if args.length > self.class::PROPERTIES.length
      fail ArgumentError, "Too many arguments"
    end

    args_keys = self.class::PROPERTIES[0...args.length]

    update(Hash[args_keys.zip(args)])
    update(kwargs)
  end

  ##
  # @param [String, Symbol] property
  # @raise [KeyError] on invalid property name
  #
  def [](property)
    property = property.to_sym

    if not valid_property? property
      fail KeyError, "Property not defined: #{property}"
    end

    @data[property]
  end

  ##
  # @param [String, Symbol] property
  # @param [Object] value
  # @raise [KeyError] on invalid property name
  #
  def []=(property, value)
    property = property.to_sym

    if not valid_property? property
      fail KeyError, "Property not defined: #{property}"
    end

    @data[property] = value
  end

  ##
  # This is simply a delegate function for the underlying hash.
  #
  # @see Hash#each
  # @overload each
  #
  def each(*args, &block)
    @data.each(*args, &block)
  end

  ##
  # Produces a text representation of the object
  #
  def inspect
    text = "#<#{self.class.to_s}"

    text << @data.reduce("") { |a, pair|
      a << " #{pair[0]}=#{pair[1].inspect}"
    }

    text << ">"

    return text
  end

  def respond_to?(method_name)
    if valid_property?(method_name) or valid_property?(getter(method_name))
      true
    else
      super
    end
  end

  ##
  # @return [Array] the values of the properties, in the right order
  #
  def to_a
    self.class::PROPERTIES.map { |name| @data[name] }
  end

  ##
  # @return [Hash] a duplicate of the underlying hash
  #
  def to_hash
    @data.dup
  end

  ##
  # Delegates to +Hash#to_json+
  #
  # @return [String]
  #
  def to_json(*args)
    @data.to_json(*args)
  end

  ##
  # Delegates to +Hash#to_yaml+
  #
  # @return [String]
  #
  def to_yaml(*args)
    @data.to_yaml(*args)
  end

  def update(hash)
    @data ||= {}

    hash.each_pair { |key, value|
      begin
        self.send(setter(key), value)
      rescue NoMethodError
        fail ArgumentError, "Invalid property: #{key}"
      end
    }
  end

  private

  ##
  # This makes the struct accept the defined properties as instance methods
  #
  def method_missing(name, *args, &block)
    property = name
    set = false

    if is_setter?(property)
      property = getter(name)
      set = true
    end

    if valid_property? property
      if set
        @data[property] = args.first
      else
        @data[property]
      end
    else
      super
    end
  end

  ##
  # Returns true if +prop+ is a valid property
  #
  def valid_property?(prop)
    self.class::PROPERTIES.include? prop
  end

  ##
  # @example
  #   is_setter?(:foo)    # => false
  #   is_setter?(:foo=)   # => true
  #
  def is_setter?(sym)
    sym.to_s.end_with?("=")
  end

  ##
  # @example
  #   setter(:foo)   # => :foo=
  #
  def setter(sym)
    (sym.to_s + "=").to_sym
  end

  ##
  # @example
  #   getter(:foo=)   # => :foo
  #   getter(:foo)    # => :foo
  #
  def getter(sym)
    if is_setter?(sym)
      sym.to_s[0..-2].to_sym
    else
      sym
    end
  end
end
