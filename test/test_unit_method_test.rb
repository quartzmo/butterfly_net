require "test/unit"
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), File.join("..", "lib"))
require "butterfly_net/definitions"
require "butterfly_net/test_unit_method"

class TestUnitMethodTest < Test::Unit::TestCase
  include ButterflyNet

  def setup
    @method = TestUnitMethod.new
    @method.name = "1"
  end

  def test_assignment_or_require_true
     assert TestUnitMethod.assignment_or_require? "a=1"
  end

#  def test_assignment_or_require_true_orequals          todo: solve orequals in regex
#     assert TestUnitMethod.assignment_or_require? "a ||= 1"
#  end

  def test_assignment_or_require_true_whitespace
     assert TestUnitMethod.assignment_or_require? "a = 1"
  end

  def test_assignment_or_require_true_contains_equals
     assert TestUnitMethod.assignment_or_require? "a = (1 == 1)"
  end

  def test_assignment_or_require_true_require_bigdecimal
     assert TestUnitMethod.assignment_or_require? "require 'bigdecimal'"
  end

  def test_assignment_or_require_true_require
     assert TestUnitMethod.assignment_or_require? "require 'rubygems'"
  end

  def test_assignment_or_require_true_require_no_spaces
     assert TestUnitMethod.assignment_or_require? "require\"rubygems\""
  end

  def test_assignment_or_require_false
     assert !TestUnitMethod.assignment_or_require?("a + 1")
  end

  def test_assignment_or_require_false_with_equals
     assert !TestUnitMethod.assignment_or_require?("a == 1")
  end

  def test_assignment_or_require_false_threequals
     assert !TestUnitMethod.assignment_or_require?("a===1")
  end

  def test_assignment_or_require_false_regex
    assert !TestUnitMethod.assignment_or_require?("'a' =~ /a/")
  end

  def test_assignment_or_require_false_regex
    assert !TestUnitMethod.assignment_or_require?("'a' =~ /a/")
  end

  def test_assignment_or_require_false_lessthanequals
    assert !TestUnitMethod.assignment_or_require?("1 <= 1")
  end

  def test_assignment_or_require_false_greaterthanequals
    assert !TestUnitMethod.assignment_or_require?("1 >= 1")
  end

  def test_assignment_or_require_false_flyingsaucer
    assert !TestUnitMethod.assignment_or_require?("1 <=> 1")
  end

  def test_assignment_or_require_false_notequal
    assert !TestUnitMethod.assignment_or_require?("1 != 0")
  end

  def test_assignment_or_require_false_modequal
    assert !TestUnitMethod.assignment_or_require?("a %= 1")
  end

  def test_assignment_or_require_false_orequal
    assert !TestUnitMethod.assignment_or_require?("a |= 1")
  end

  def test_assignment_or_require_false_plusequal
    assert !TestUnitMethod.assignment_or_require?("a += 1")
  end

  def test_assignment_or_require_false_minusequal
    assert !TestUnitMethod.assignment_or_require?("a -= 1")
  end

  def test_assignment_or_require_false_divideequal
    assert !TestUnitMethod.assignment_or_require?("a /= 1")
  end

  def test_assignment_or_require_false_andequal
    assert !TestUnitMethod.assignment_or_require?("a &= 1")
  end

  def test_assignment_or_require_false_shiftrightequal
    assert !TestUnitMethod.assignment_or_require?("a >>= 1")
  end

  def test_assignment_or_require_false_shiftleftequal
    assert !TestUnitMethod.assignment_or_require?("a <<= 1")
  end

  def test_assignment_or_require_false_timesequal
    assert !TestUnitMethod.assignment_or_require?("a *= 1")
  end

  def test_name_uppercase
    @method.name = "MYMETHOD"
    assert_equal("test_mymethod", @method.name)
  end

  def test_name_camelcase
    @method.name = "MyMethod"
    assert_equal("test_my_method", @method.name)
  end

  def test_name_hyphenated
    @method.name = "my-Method"
    assert_equal("test_my_method", @method.name)
  end

  def test_name_spaces
    @method.name = " my Method "
    assert_equal("test_my_method", @method.name)
  end

  def test_test_methods_naming_no_changes
    @method.name = 'test_one_plus_one'
    assert_equal("test_one_plus_one", @method.name)
  end

  def test_test_methods_naming_prepends_test
    @method.name = 'one_plus_one'
    assert_equal("test_one_plus_one", @method.name)
  end



#  def test_text_split_expressions_into_lines      todo
#    @method.write_expression "a = 1; a + 1"
#    assert_equal "def test_1\n    a = 1\n    assert_equal(2, a + 1)\n  end", @method.text
#  end

  def test_purge_unexpected_identifier
    @method.write_expression "a = 1", 1
    @method.write_expression "2b", nil, SyntaxError.new("compile error")
    @method.write_expression "a += 1", 2
    assert_equal "  def test_1\n    a = 1\n    # 2b   # SyntaxError: compile error\n    assert_equal(2, a += 1)\n  end\n\n", @method.text
  end

  def test_purge_unexpected_identifiers
    @method.write_expression "a += 1", nil, NoMethodError.new("undefined method `+' for nil:NilClass")
    @method.write_expression "a = 1", 1
    @method.write_expression "a += 1", 2
    assert_equal "  def test_1\n    # a += 1   # NoMethodError: undefined method `+' for nil:NilClass\n    a = 1\n    assert_equal(2, a += 1)\n  end\n\n", @method.text
  end

  def test_text_require
    @method.write_expression "require 'rubygems'", "true"
    @method.write_expression "require'active_support'", "true"
    @method.write_expression "'CamelCase'.underscore", "camel_case"
    assert_equal "  def test_1\n    require 'rubygems'\n    require'active_support'\n    assert_equal(\"camel_case\", 'CamelCase'.underscore)\n  end\n\n", @method.text
  end

  def test_expected_boolean
    line = "1 == 1"
    @method.write_expression line, true
    assert_equal("assert(#{line})", @method.lines[0])
  end

  def test_assertion_fixnum
    line = "1"
    @method.write_expression line, 1
    assert_equal("assert_equal(#{line}, #{line})", @method.lines[0])
  end

  def test_assertion_boolean_false
    line = "1 != 1"
    @method.write_expression line, false
    assert_equal("assert_equal(false, #{line})", @method.lines[0])
  end

  def test_array_add
    @method.write_expression "a = []", []
    line2 = "a << \"1\""
    @method.write_expression line2, ["1"]
    assert_equal("assert_equal([\"1\"], #{line2})", @method.lines[1])
  end

  def test_butterfly_net
    @method.write_expression "method = TestUnitMethod.new", nil   # todo: replace nil with real result, or result.inspect
    @method.write_expression "method.write_expression(\"1 + 1\")", "assert_not_nil(method.write_expression(\"1 + 1\"))"
    assert_equal("assert_not_nil(method.write_expression(\"1 + 1\"))", @method.lines[1])
  end

  def test_assertion_boolean
    line = "1 == 1"
    @method.write_expression line, true
    assert_equal("assert(#{line})", @method.lines[0])
  end

  def test_assertion_string
    line = "'a' + 'b'"
    @method.write_expression line, "ab"
    assert_equal("assert_equal(\"ab\", #{line})", @method.lines[0])
  end

  def test_assertion_nil
    line = "[].first"
    @method.write_expression line, nil
    assert_equal("assert_nil(#{line})", @method.lines[0])
  end

  def test_assertion_boolean
    line = "1 == 1"
    @method.write_expression line, true
    assert_equal("assert(#{line})", @method.lines[0])
  end

  def test_assertion_object_not_equal
    line = "Object.new"
    @method.write_expression line, Object.new  # todo: replace nil with real result, or result.inspect
    assert_equal("assert_not_nil(#{line})", @method.lines[0])
  end

  def test_assertion_array
    line = "([1,2,3])[0..0]"
    @method.write_expression line, [1]
    assert_equal("assert_equal([1], #{line})", @method.lines[0])
  end

  def test_text_def_method_single_line
    @method.write_expression "def timestwo(i); i * 2; end", nil
    line = "timestwo(2)"
    @method.write_expression line, 4
    assert_equal("  def timestwo(i); i * 2; end\n\n  def test_1\n    assert_equal(4, #{line})\n  end\n\n", @method.text)
  end

  def test_text_illegal_input
    line = "badtext"
    @method.write_expression line, nil, NameError.new("first line of exception")
    assert_equal "  def test_1\n    # badtext   # NameError: first line of exception\n  end\n\n", @method.text
  end

  def test_text
    @method.write_expression "1 + 1", 2
    assert_equal "  def test_1\n    assert_equal(2, 1 + 1)\n  end\n\n", @method.text
  end

  def test_text_variable_assignment_only
    line = "a = 1"
    @method.write_expression line, 1
    assert_equal "  def test_1\n    #{line}\n  end\n\n", @method.text
  end

#  todo: reinstate once lines are replaced with expressions, as in irb_workspace branch
#
  def test_text_block_using_variable
    @method.write_expression "a = 5", 5
    @method.write_expression "b = 0", 0
    @method.write_expression "a.times do\nb += a\nend", 5  #result is number of times 
    @method.write_expression "b", 25
    expected = <<-EOF
  def test_1
    a = 5
    b = 0
    a.times do
      b += a
    end
    assert_equal(b, 25)
  end
    EOF
    assert_equal expected, @method.text
  end

  def test_definitions_class_multiline_empty
    line = "class MyClass"
    line2 = "end"
    line3 = "MyClass.new"
    @method.write_expression line + "\n" + line2, nil
    @method.write_expression line, nil   # todo: replace nil with real result, or result.inspect
    assert_equal "  #{line}\n  #{line2}\n\n  def test_1\n    assert_not_nil(#{line3})\n  end\n\n", @method.text
  end

  def test_definitions_class_with_method
    @method.write_expression "class MyClass\ndef name\n\"classy\"\nend\nend", nil
    @method.write_expression "MyClass.new.name", "classy"
    assert_equal "  class MyClass\n    def name\n      \"classy\"\n    end\n  end\n\n  def test_1\n    assert_equal(\"classy\", MyClass.new.name)\n  end\n\n", @method.text
  end

  def test_text_bad_input_constant
    @method.write_expression "BADCONSTANT", nil, NameError.new("uninitialized constant BADCONSTANT")
    assert_equal "  def test_1\n    # BADCONSTANT   # NameError: uninitialized constant BADCONSTANT\n  end\n\n", @method.text
  end



  # non-project tests (scratchpad)

  def test_eval_scope
    value = eval "a = []\na << 1", Proc.new {}.binding
    assert_equal([1], value)
    assert_equal([1,1], eval("a << 1", Proc.new {}.binding))
  end

end