
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

    self.update(*args)
    self.update(**kwargs)
  end

  ##
  # Delegates to +Hash#each+
  #
  # @see http://ruby-doc.org/core-2.0.0/Hash.html#method-i-each Hash#each
  # @overload each
  #
  def each(*args, &block)
    @data.each(*args, &block)
  end

  ##
  # Returns a property using its getter method
  #
  # @param [String, Symbol] property
  # @raise [KeyError] on invalid property name
  #
  def get(property)
    property = property.to_sym

    if not valid_property? property
      fail KeyError, "Property not defined: #{property}"
    end

    self.send(property)
  end

  alias_method :[], :get

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
  # Sets the value of a property using its setter method
  #
  # @param [String, Symbol] property
  # @param [Object] value
  # @raise [KeyError] on invalid property name
  #
  def set(property, value)
    property = property.to_sym

    if not valid_property? property
      fail KeyError, "Property not defined: #{property}"
    end

    self.send(setter(property), value)
  end

  alias_method :[]=, :set

  ##
  # Returns the properties of the object as an array
  #
  # @return [Array]
  #
  def to_array
    self.class::PROPERTIES.map { |name| @data[name] }
  end

  alias_method :to_a, :to_array

  ##
  # Returns the properties of the object as a hash
  #
  # @return [Hash]
  #
  def to_hash
    @data.dup
  end

  alias_method :to_h, :to_hash

  ##
  # Dumps the properties of this object to JSON using Ruby's JSON module
  #
  # @note JSON must be loaded for this function to work
  # @see http://www.ruby-doc.org/stdlib-2.0/libdoc/json/rdoc/JSON.html JSON
  # @return [String]
  #
  def to_json(*args)
    @data.to_json(*args)
  end

  ##
  # Dumps the properties of this object to YAML using Ruby's YAML module
  #
  # @note YAML must be loaded for this function to work
  # @see http://ruby-doc.org/stdlib-2.0.0/libdoc/yaml/rdoc/YAML.html YAML
  # @return [String]
  #
  def to_yaml(*args)
    @data.to_yaml(*args)
  end

  ##
  # Updates the values of this object's properties
  #
  # Both positional arguments and keyword arguments are used to update the
  # property values of the object. Positional arguments should be passed in the
  # same order as the defined properties.
  #
  # @note Keyword arguments override posisional arguments
  # @raise [ArgumentError] on invalid property names
  # @return nil
  #
  def update(*args, **kwargs)
    @data ||= {}

    if args.length > self.class::PROPERTIES.length
      x = args.length
      y = self.class::PROPERTIES.length
      msg = "Too many arguments (you passed #{x} arguments for #{y} properties)"

      fail ArgumentError, msg
    end

    hash = Hash[self.class::PROPERTIES[0...args.length].zip(args)]
    hash.update(kwargs)

    hash.each_pair { |key, value|
      begin
        self.set(key, value)
      rescue KeyError => e
        fail ArgumentError, "Invalid property: #{key}"
      end
    }

    nil
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
