require "test/unit"
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), File.join("..", "lib"))
require "butterfly_net/test_unit_method"

class TestUnitMethodTest < Test::Unit::TestCase
  include ButterflyNet

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
    assert_equal("assert(#{line})", @method.expected_assertion(0))
  end

  def test_assertion_fixnum
    line = "1"
    @method << line
    assert_equal("assert_equal(#{line}, #{line})", @method.expected_assertion(0))
  end

  def test_assertion_boolean_false
    line = "1 != 1"
    @method << line
    assert_equal("assert_equal(false, #{line})", @method.expected_assertion(0))
  end



  def test_array_add
    @method << "a = []"
    line2 = "a << \"1\""
    @method << line2
    assert_equal("assert_equal([\"1\"], #{line2})", @method.expected_assertion(1))
  end

  def test_butterfly_net
    @method << "method = TestUnitMethod.new"
    @method << "method << \"1 + 1\""
    assert_equal("assert_equal([\"1 + 1\"], method << \"1 + 1\")", @method.expected_assertion(1))
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
    assert_equal("assert_nil(#{line})", @method.text_from_expression(line, 0))
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

  # non-project tests (scratchpad)

  def test_eval_scope
    value = eval "a = []\na << 1", Proc.new {}.binding
    assert_equal([1], value)
    assert_equal([1,1], eval("a << 1", Proc.new {}.binding))
  end

end