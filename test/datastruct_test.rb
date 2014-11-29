
class DataStructFactoryTest < Minitest::Test
  def setup
    @subject = DataStruct(:foo, :bar) {
      def self.bark
        :dog
      end

      def meow
        :cat
      end
    }
  end

  def test_subclass
    assert_same DataStruct, @subject.superclass
  end

  def test_properties
    assert_equal [:foo, :bar], @subject::PROPERTIES
  end

  def test_class_eval_block
    assert_equal :dog, @subject.bark
    assert_equal :cat, @subject.new.meow
  end
end

class DataStructClassTest < Minitest::Test
  def setup
    @subject = DataStruct(:foo, :bar, :baz)
  end

  def test_from_array
    array = [1, 2, 3]
    struct = @subject.from_array(array)

    assert_equal array, struct.to_a
    assert_instance_of @subject, struct
  end

  def test_from_hash
    hash = {foo: 12, bar: 34, baz: 56}
    struct = @subject.from_hash(hash)

    assert_equal hash, struct.to_hash
    assert_instance_of @subject, struct
  end

  def test_invalid_from_hash
    hash = {quack: 12}

    assert_raises(KeyError) {
      @subject.from_hash hash
    }
  end
end

class DataStructTest < Minitest::Test
  def setup
    @subject = DataStruct(:foo, :bar, :baz).new(12, 34, 56)
  end

  def test_property_lookup
    assert_equal 34, @subject.bar
  end

  def test_invalid_property_lookup
    assert_raises(NoMethodError) {
      @subject.meow
    }
  end

  def test_property_setting
    @subject.baz = 78
    assert_equal 78, @subject.baz
  end

  def test_invalid_property_setting
    assert_raises(NoMethodError) {
      @subject.meow = 123
    }
  end

  def test_hash_lookup
    assert_equal 56, @subject[:baz]
  end

  def test_string_hash_lookup
    assert_equal 56, @subject["baz"]
  end

  def test_invalid_hash_lookup
    assert_raises(KeyError) {
      @subject[:meow]
    }
  end

  def test_hash_setting
    @subject[:foo] = 78
    assert_equal 78, @subject[:foo]
  end

  def test_string_hash_setting
    @subject["foo"] = 78
    assert_equal 78, @subject[:foo]
  end

  def test_invalid_hash_setting
    assert_raises(KeyError) {
      @subject[:meow] = 123
    }
  end

  def test_update
    @subject.expects(:foo=).with(123)
    @subject.update(foo: 123)
  end

  def test_to_hash
    assert_equal({foo: 12, bar: 34, baz: 56}, @subject.to_hash)
  end

  def test_to_hash_incomplete
    @subject.bar = nil

    assert_equal({foo: 12, bar: nil, baz: 56}, @subject.to_hash)
  end

  def test_to_a
    assert_equal([12, 34, 56], @subject.to_a)
  end

  def test_each
    subject_hash = @subject.to_hash
    each_hash = {}

    @subject.each { |key, value|
      each_hash[key] = value
    }

    assert_equal subject_hash, each_hash
  end

  def test_each_enumerator
    enum = @subject.each
    assert_instance_of Enumerator, enum

    subject_pairs = @subject.to_hash.to_a
    assert_equal subject_pairs, enum.to_a
  end

  def test_respond_to?
    assert_respond_to @subject, :foo
    assert_respond_to @subject, :baz=
    refute_respond_to @subject, :meow
    refute_respond_to @subject, :quack=
  end
end
