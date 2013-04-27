require "test_helper"

class BooleanSchemaTest < Test::Unit::TestCase
  def test_boolean_schema_validate_format
    [
      [ "42", nil, "integer in string" ],
      [ { "test" => 42 }, nil, "object" ],
      [ "true", true, "valid true value" ],
      [ "false", false, "valid false value" ],
      [ true, true, "true" ],
      [ false, false, "false" ],
      [ "nil", nil, "nil in string" ],
    ].each do |data|
      s = Respect::BooleanSchema.new
      # Check validate_format
      if data[1].nil?
        assert_raise(Respect::ValidationError) do
          s.validate_format(data[0])
        end
      else
        assert_equal data[1], s.validate_format(data[0]), data[2]
      end
      # Check sanitized_doc
      assert_nil s.sanitized_doc
      assert_equal (data[1].nil? ? false : true), s.validate?(data[0]), data[2]
      unless data[1].nil?
        assert_equal data[1], s.sanitized_doc, data[2]
      end
    end
  end

  def test_boolean_schema_accept_constraint_equal_to
    s_true = Respect::BooleanSchema.new equal_to: true
    assert_equal true, s_true.validate?("true")
    assert_equal false, s_true.validate?("false")

    s_false = Respect::BooleanSchema.new equal_to: false
    assert_equal false, s_false.validate?("true")
    assert_equal true, s_false.validate?("false")
  end

end