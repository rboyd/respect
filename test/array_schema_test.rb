require "test_helper"

class ArraySchemaTest < Test::Unit::TestCase
  def test_items_validate
    s = Respect::ArraySchema.define do |s|
      s.integer greater_than: 0
    end
    assert s.validate?([ ]), "empty array"
    assert s.validate?([ 42 ]), "single item"
    assert s.validate?([ 42, 51 ]), "two items"
    assert s.validate?([ 42, 51, 51 ]), "several items"
    # Single item's value validation fail.
    assert_raise(Respect::ValidationError) do
      assert s.validate([ 0 ])
    end
    # Single item's key validation fail.
    assert_raise(Respect::ValidationError) do
      assert s.validate([ { "test" => 42 } ])
    end
    # One item in the list is invalid.
    assert_raise(Respect::ValidationError) do
      assert s.validate([ 52, 0, 42 ])
    end
  end

  def test_items_array_validate
    s = Respect::ArraySchema.define do |s|
      s.array do |s|
        s.integer greater_than: 0
      end
    end
    assert s.validate?([ ]), "empty array"
    assert s.validate?([ [42] ]), "single nested items"
    assert !s.validate?([ [42], 51 ]), "second item is not array"
    assert s.validate?([ [42, 51] ]), "several nested items"
    assert s.validate?([ [42, 51], [62, 64] ]), "several, several nested items"
  end

  def test_items_array_validate_array
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer greater_than: 0
        s.integer equal_to: 42
        s.integer equal_to: 51
      end
    end
    assert !s.validate?([ ]), "empty array"
    assert s.validate?([ 1, 42, 51 ]), "valid"
    assert !s.validate?([ 0, 42, 51 ]), "first item invalid"
    assert !s.validate?([ 1, 40, 51 ]), "second item invalid"
    assert !s.validate?([ 1, 42, 50 ]), "third item invalid"
    assert !s.validate?([ 42, 51 ]), "not enough items"
    assert !s.validate?([ 1, 42, 51, 0 ]), "too many items"
  end

  def test_cannot_mix_single_item_and_multiple_items_validation
    assert_raise(Respect::InvalidSchemaError) do
      Respect::ArraySchema.define do |s|
        s.integer greater_than: 0
        s.items do |s|
          s.integer greater_than: 0
        end
      end
    end
    assert_raise(Respect::InvalidSchemaError) do
      Respect::ArraySchema.define do |s|
        s.items do |s|
          s.integer greater_than: 0
        end
        s.integer greater_than: 0
      end
    end
  end

  def test_cannot_mix_single_item_and_extra_items_validation
    assert_raise(Respect::InvalidSchemaError) do
      Respect::ArraySchema.define do |s|
        s.integer greater_than: 0
        s.extra_items do |s|
          s.integer greater_than: 0
        end
      end
    end
    assert_raise(Respect::InvalidSchemaError) do
      Respect::ArraySchema.define do |s|
        s.extra_items do |s|
          s.integer greater_than: 0
        end
        s.integer greater_than: 0
      end
    end
  end

  def test_extra_items_validate_array
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer greater_than: 0
        s.integer equal_to: 42
      end
      s.extra_items do |s|
        s.integer equal_to: 51
        s.integer equal_to: 64
      end
    end
    assert !s.validate?([ ]), "empty array"
    assert s.validate?([ 1, 42 ]), "no extra items"
    assert s.validate?([ 1, 42, 51, 64 ]), "extra items"
    assert s.validate?([ 1, 42, 51 ]), "missing extra item"
    assert s.validate?([ 1, 42, 51, 64, 80 ]), "additional extra item"
    assert !s.validate?([ 1, 42, 52, 64 ]), "first extra item invalid"
    assert !s.validate?([ 1, 42, 51, 65 ]), "second extra item invalid"
    assert !s.validate?([ 1, 42, 52, 65 ]), "all extra item invalid"
  end

  def test_extra_items_with_no_items_validate_array
    s = Respect::ArraySchema.define do |s|
      s.extra_items do |s|
        s.integer equal_to: 51
        s.integer equal_to: 64
      end
    end
    assert s.validate?([ ]), "no extra items"
    assert s.validate?([ 51, 64 ]), "extra items"
    assert s.validate?([ 51 ]), "missing extra item"
    assert s.validate?([ 51, 64, 80 ]), "additional extra item"
    assert !s.validate?([ 52, 64 ]), "first extra item invalid"
    assert !s.validate?([ 51, 65 ]), "second extra item invalid"
    assert !s.validate?([ 52, 65 ]), "all extra item invalid"
  end

  def test_array_schema_do_not_validate_other_type
    s = Respect::ArraySchema.define do |s|
      s.integer greater_than: 0
    end
    [
      { "test" => 0 },
      42,
      "test",
      nil,
    ].each do |doc|
      assert_raise(Respect::ValidationError) do
        s.validate(doc)
      end
    end
  end

  def test_array_min_size_constraint
    s = Respect::ArraySchema.define min_size: 2 do |s|
      s.integer greater_than: 0
    end
    assert !s.validate?([ ]), "empty array"
    assert !s.validate?([ 1 ]), "one item"
    assert s.validate?([ 1, 2 ]), "two items"
    assert s.validate?([ 1, 2, 3 ]), "three items"
  end

  def test_array_max_size_constraint
    s = Respect::ArraySchema.define max_size: 2 do |s|
      s.integer greater_than: 0
    end
    assert s.validate?([ ]), "empty array"
    assert s.validate?([ 1 ]), "one item"
    assert s.validate?([ 1, 2 ]), "two items"
    assert !s.validate?([ 1, 2, 3 ]), "three items"
    assert !s.validate?([ 1, 2, 3, 4 ]), "four items"
  end

  def test_array_unique_constraint
    s = Respect::ArraySchema.define uniq: true do |s|
      s.integer greater_than: 0
    end
    assert s.validate?([ ]), "empty array"
    assert s.validate?([ 1 ]), "one item"
    assert s.validate?([ 1, 2 ]), "two different items"
    assert !s.validate?([ 1, 2, 1 ]), "one duplicated item"
    assert !s.validate?([ 1, 2, 1, 2 ]), "two duplicated items"
  end

  def test_object_in_array_validate
    s = Respect::ArraySchema.define do |s|
      s.object do |s|
        s.numeric "prop", equal_to: 51
      end
    end
    assert s.validate?([ { "prop" => 51 } ])
    assert !s.validate?([ { "prop" => 42 } ])
  end

  def test_object_in_array_in_object_validate
    s = Respect::ObjectSchema.define do |s|
      s.array "level_1" do |s|
        s.object do |s|
          s.numeric "level_3", equal_to: 51
        end
      end
    end
    assert s.validate?({ "level_1" => [ { "level_3" => 51 } ]})
    assert !s.validate?({ "level_1" => [ { "level_3" => 42 } ]})
  end

  def test_doc_updated_with_sanitized_value
    s = Respect::ArraySchema.define do |s|
      s.integer
    end
    doc = [ "42", "51", "16" ]
    assert_not_nil s.validate!(doc)
    assert_equal [ 42, 51, 16 ], doc
  end

  def test_doc_updated_with_sanitized_value_with_custom_type
    s = Respect::ObjectSchema.define do |s|
      s.rgba "color"
    end
    doc = { "color" => [ "0.0", "0.5", "1.0", "0.2" ] }
    assert_validate! s, doc
    assert_equal Rgba.new(0.0, 0.5, 1.0, 0.2), doc["color"]
  end

  def test_recursive_doc_updated_with_sanitized_value
    s = Respect::ArraySchema.define do |s|
      s.array do |s|
        s.integer
      end
    end
    doc = [ [ "42" ], [ "51" ], [ "16" ] ]
    assert_not_nil s.validate!(doc)
    assert_equal [ [ 42 ], [ 51 ], [ 16 ] ], doc
  end

  def test_multi_items_doc_updated_with_sanitized_value
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer
        s.array do |s|
          s.integer
        end
      end
    end
    doc = [ "42", [ "51" ] ]
    assert_not_nil s.validate!(doc)
    assert_equal [ 42, [ 51 ] ], doc
  end

  def test_only_update_validated_items
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer
      end
      s.extra_items do |s|
        s.integer
      end
    end
    doc = [ "42", "51", "64" ]
    assert_not_nil s.validate!(doc)
    assert_equal [ 42, 51, "64" ], doc
  end

  def test_only_update_recursive_validated_items
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.array do |s|
          s.items do |s|
            s.integer
          end
          s.extra_items do |s|
            s.integer
          end
        end
      end
    end
    doc = [ [ "42", "51", "64" ] ]
    assert_not_nil s.validate!(doc)
    assert_equal [ [ 42, 51, "64" ] ], doc
  end

  def test_sanitize_simple_document
    s = Respect::ArraySchema.define do |s|
      s.integer
    end
    doc = [ "42", "51" ]
    assert_nil s.sanitized_doc
    s.validate(doc)
    assert_equal([ "42", "51" ], doc)
    assert_equal([ 42, 51 ], s.sanitized_doc)
  end

  def test_sanitize_recursive_document
    s = Respect::ArraySchema.define do |s|
      s.array do |s|
        s.integer
      end
    end
    doc = [ [ "42", "51" ], [ "16" ] ]
    assert_nil s.sanitized_doc
    s.validate(doc)
    assert_equal([ [ "42", "51" ], [ "16" ] ], doc)
    assert_equal([ [ 42, 51 ], [ 16 ] ], s.sanitized_doc)
  end

  def test_do_not_sanitize_unvalidated_optional_property
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer
      end
      s.extra_items do |s|
        s.integer
      end
    end
    doc = [ "42" ]
    assert_nil s.sanitized_doc
    s.validate(doc)
    assert_equal([ "42" ], doc)
    assert_equal([ 42 ], s.sanitized_doc)
  end

  def test_sanitize_validated_optional_property
    s = Respect::ArraySchema.define do |s|
      s.items do |s|
        s.integer
      end
      s.extra_items do |s|
        s.integer
      end
    end
    doc = [ "42", "52", "16" ]
    assert_nil s.sanitized_doc
    s.validate(doc)
    assert_equal([ "42", "52", "16" ], doc)
    assert_equal([ 42, 52 ], s.sanitized_doc)
  end

  def test_block_must_take_one_arg
    assert_raise(ArgumentError) do
      s = Respect::ArraySchema.define do |s, a|
      end
    end
    assert_raise(ArgumentError) do
      s = Respect::ArraySchema.define do
      end
    end
  end

  def test_array_schema_merge_default_options
    s = Respect::ArraySchema.new
    assert_equal true, s.options[:required]
    assert_equal false, s.options[:uniq]
  end

  def test_array_schema_merge_options
    s = Respect::ArraySchema.new(opt: 1, uniq: true)
    assert_equal true, s.options[:required]
    assert_equal true, s.options[:uniq]
    assert_equal 1, s.options[:opt]
  end

  def test_non_default_options
    s = Respect::ArraySchema.new(opt: 1, uniq: true)
    opts = s.non_default_options
    assert !opts.has_key?(:required)
    assert_equal true, opts[:uniq]
    assert_equal 1, opts[:opt]
  end

end