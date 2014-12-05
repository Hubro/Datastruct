
# Datastruct

Datastruct exists because I like [Struct][Struct], but want more power.

## Usage examples

### Creating a DataStruct subclass

If you're in a hurry, you can use the factory function:

```ruby
StreetAddress = DataStruct(:address, :postal_code, :city) {
  def to_s
    "#{address}, #{postal_code} #{city}"
  end
}
```

Alternatively, you can subclass `DataStruct` yourself. This is recommended if
you want the class to be documented by an automatic documentation tool like
YARD:

```ruby
class StreetAddress < DataStruct
  PROPERTIES = [:address, :postal_code, :city]

  def to_s
    "#{address}, #{postal_code} #{city}"
  end
end
```

### Creating instances

Datastruct comes with a constructor method that passes all arguments to
`DataStruct#update`:

```ruby
sesame_street = StreetAddress.new("Sesame street 1", 10023, "New York")

sesame_street = StreetAddress.new(
  address: "Sesame street 1", postal_code: 10023, city: "New York"
)
```

In case you want to override the constructor, Datastruct also comes with these
two class methods:

```ruby
sesame_street = StreetAddress.from_array(["Sesame street 1", 10023, "New York"])

sesame_street = StreetAddress.from_hash(
  {address: "Sesame street 1", postal_code: 10023, city: "New York"}
)
```

### Getting and setting properties

Datastruct defined the methods `get` and `set`, which is used internally by
`[]`, `[]=` and `update`. Both `get` and `set` accepts a property name in the
form of a string or symbol, and gets/sets the property **using the accessor
method**.

To illustrate, here are some examples:

```ruby
# This is a simple assignment using a setter method:
sesame_street.street_name = "Sesame street 2"

# *All* the following method calls are functionally *identical* to the line
# above:
sesame_street.set(:street_name, "Sesame street 2")
sesame_street.set("street_name", "Sesame street 2")
sesame_street[:street_name] = "Sesame street 2"
sesame_street["street_name"] = "Sesame street 2"
sesame_street.update(street_name: "Sesame street 2")
sesame_street.update("Sesame street 2")
```

The last line might be confusing. The `update` method accepts keyword arguments
and passes the values along to the setter methods, but it also accepts
positional arguments. The first positional argument is used as the value of the
first property, and so on. Example:

```ruby
sesame_street.update("Sesame street 3", 10023, "New York")
```

The fact that the accessor methods is used internally is significant. This means
that you can override accessor methods to perform input validation or
processing. Example:

```ruby
# Extending the previously defined StreetAddress for brevity
class StreetAddress
  def postal_code=(postal_code)
    if postal_code != 10023
      raise ArgumentError, "Invalid postal code!"
    end

    super

    # Or:
    # @data[:postal_code] = postal_code
  end
end

sesame_street = StreetAddress.new

# The input validation will be performed no matter what method you use to set
# the value. All these statements will now raise an argument error:
sesame_street.postal_code = 123
sesame_street.set(:postal_code, 123)
sesame_street[:postal_code] = 123
sesame_street.update(postal_code: 123)
sesame_street.update("Sesame street 4", 123, "New York")
```

Another example:

```ruby
# Extending the previously defined StreetAddress for brevity
class StreetAddress
  def street_name
    super.upcase

    # Or:
    # @data[:street_name].upcase
  end
end

sesame_street = StreetAddress.new(street_name: "Sesame street 5")

# All these statements return "SESAME STREET 5":
sesame_street.street_name
sesame_street.get(:street_name)
sesame_street[:street_name]
```

## Internals

Datastruct is very simple. It has four core components:

  - The `PROPERTIES` constant
  - The `@data` instance variable
  - The `method_missing?` override, which lets you use accessor style methods
    for getting and setting property values
  - The `get` and `set` methods, which internally uses the accessor methods

Additionally, Datastruct defines:

  - `#update`, for easily updating multiple property values from a hash or an
    array
  - `#[]` and `#[]=`, which are aliases for `get` and `set`
  - `#inspect` which returns a pretty string representation of the instance
  - `#respond_to?` override for the default property getters and setters
  - `#to_array`/`#to_a` which returns an array of the property values
  - `#to_hash`/`#to_h` which returns a hash of the property values
  - `#to_json` which dumps the internal hash to JSON
  - `#to_yaml` which dumps the internal hash to YAML

[Struct]: http://www.ruby-doc.org/core-2.0/Struct.html
