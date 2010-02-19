require "test/unit"
require "../lib/test_unit_method"

class TestUnitMethodTest < Test::Unit::TestCase

  def setup
    @method = TestUnitMethod.new
  end

  def test_assigns_variable_true
     assert TestUnitMethod.assigns_variable? "a=1"
  end

  def test_assigns_variable_true_whitespace
     assert TestUnitMethod.assigns_variable? "a = 1"
  end

  def test_assigns_variable_true_contains_equals
     assert TestUnitMethod.assigns_variable? "a = (1 == 1)"
  end

  def test_assigns_variable_false
     assert !TestUnitMethod.assigns_variable?("a + 1")
  end

  def test_assigns_variable_false_with_equals
     assert !TestUnitMethod.assigns_variable?("a == 1")
  end

  def test_assigns_variable_false_threequals
     assert !TestUnitMethod.assigns_variable?("a===1")
  end

  def test_expected_boolean
    line = "1 == 1"
    @method << line
    assert_equal("true", @method.expected(0))
  end

  def test_assertion_boolean
    line = "1 == 1"
    assert_equal("assert(#{line})", TestUnitMethod.assertion("true", line))
  end

  def test_text_from_expression_boolean
    line = "1 == 1"
    @method << line
    assert_equal("assert(#{line})", @method.text_from_expression(line, 0))
  end

  def test_text_from_expression_string
    line = "'a' + 'b'"
    @method << line
    assert_equal("assert_equal(\"ab\", #{line})", @method.text_from_expression(line, 0))
  end

  def test_text_from_expression_nil
    line = "[].first"
    @method << line
    assert_equal("assert_equal(nil, #{line})", @method.text_from_expression(line, 0))
  end

  def test_text_from_expression_boolean
    line = "1 == 1"
    @method << line
    assert_equal("assert(#{line})", @method.text_from_expression(line, 0))
  end

  def test_text_from_expression_object_not_equal
    line = "Object.new"
    @method << line
    assert_equal("assert_not_equal((#{line}), #{line})", @method.text_from_expression(line, 0))
  end

  def test_text_from_expression_array
    line = "([1,2,3])[0..0]"
    @method << line
    assert_equal("assert_equal([1], #{line})", @method.text_from_expression(line, 0))
  end

  def test_text_from_expression_illegal_input
    line = "BADCOMMAND"
    @method << line
    assert_nil @method.text_from_expression(line, 0)
  end

end