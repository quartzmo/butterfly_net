require "test/unit"
require "../lib/test_unit_method"

class TestUnitMethodTest < Test::Unit::TestCase

  def setup
    @method = TestUnitMethod.new
  end

  def test_assigns_variable_true
     assert @method.assigns_variable? "a = 1"
  end

  def test_assigns_variable_false
     assert !@method.assigns_variable?("a + 1")
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

  def test_text_from_expression_array
    line = "Object.new"
    @method << line
    assert_equal("assert_not_equal((#{line}), #{line})", @method.text_from_expression(line, 0))
  end

  def test_text_from_expression_illegal_input
    line = "BADCOMMAND"
    @method << line
    assert_nil @method.text_from_expression(line, 0)
  end

end