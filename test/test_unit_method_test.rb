require "test/unit"
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), File.join("..", "lib"))
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

  def test_method_def_true_whitespace
    assert TestUnitMethod.start_def?(" def timestwo(i); i * 2; end ")
  end

  def test_class_def_true_whitespace
    assert TestUnitMethod.start_def?(" class MyClass; end ")
  end

  def test_class_def_true_whitespace
    assert TestUnitMethod.start_def?(" module MyModule; end ")
  end

  def test_method_def_false_variable
    assert !TestUnitMethod.start_def?("definite == true ")
  end


  def test_start_def_true_inline
    assert TestUnitMethod.start_def?(" def timestwo(i); i * 2; end ")
  end

  def test_end_def_true_inline
    assert TestUnitMethod.end_def?(" def timestwo(i); i * 2; end ")
  end

  def test_end_def_true_whitespace
    assert TestUnitMethod.end_def?(" end ")
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



#  def test_text_split_statements_into_lines      todo
#    @method << "a = 1; a + 1"
#    assert_equal "def test_1\n    a = 1\n    assert_equal(2, a + 1)\n  end", @method.text
#  end

  def test_purge_unexpected_identifier
    @method << "a = 1"
    @method << "2b" # syntax error, unexpected tIDENTIFIER, expecting $end
    @method << "a += 1"
    assert_equal "  def test_1\n    a = 1\n    assert_equal(2, a += 1)\n  end\n\n", @method.text
  end

  def test_purge_unexpected_identifiers
    @method << "a += 1"  # undefined method `+' for nil:NilClass
    @method << "a = 1"
    @method << "a += 1"
    assert_equal "  def test_1\n    a = 1\n    assert_equal(2, a += 1)\n  end\n\n", @method.text
  end

  def test_text_require
    @method << "require 'rubygems'"
    @method << "require'active_support'"
    @method << "'CamelCase'.underscore"
    assert_equal "  def test_1\n    require 'rubygems'\n    require'active_support'\n    assert_equal(\"camel_case\", 'CamelCase'.underscore)\n  end\n\n", @method.text
  end

  def test_expected_boolean
    line = "1 == 1"
    @method << line
    assert_equal("assert(#{line})", @method.assertion(0))
  end

  def test_assertion_fixnum
    line = "1"
    @method << line
    assert_equal("assert_equal(#{line}, #{line})", @method.assertion(0))
  end

  def test_assertion_boolean_false
    line = "1 != 1"
    @method << line
    assert_equal("assert_equal(false, #{line})", @method.assertion(0))
  end

  def test_array_add
    @method << "a = []"
    line2 = "a << \"1\""
    @method << line2
    assert_equal("assert_equal([\"1\"], #{line2})", @method.assertion(1))
  end

  def test_butterfly_net
    @method << "method = TestUnitMethod.new"
    @method << "method << \"1 + 1\""
    assert_equal("assert_equal([\"1 + 1\"], method << \"1 + 1\")", @method.assertion(1))
  end

  def test_assertion_boolean
    line = "1 == 1"
    @method << line
    assert_equal("assert(#{line})", @method.assertion(0))
  end

  def test_assertion_string
    line = "'a' + 'b'"
    @method << line
    assert_equal("assert_equal(\"ab\", #{line})", @method.assertion(0))
  end

  def test_assertion_nil
    line = "[].first"
    @method << line
    assert_equal("assert_nil(#{line})", @method.assertion(0))
  end

  def test_assertion_boolean
    line = "1 == 1"
    @method << line
    assert_equal("assert(#{line})", @method.assertion(0))
  end

  def test_assertion_object_not_equal
    line = "Object.new"
    @method << line
    assert_equal("assert_not_equal((#{line}), #{line})", @method.assertion(0))
  end

  def test_assertion_array
    line = "([1,2,3])[0..0]"
    @method << line
    assert_equal("assert_equal([1], #{line})", @method.assertion(0))
  end

  def test_text_def_method_single_line
    @method << "def timestwo(i); i * 2; end"
    line = "timestwo(2)"
    @method << line
    assert_equal("  def timestwo(i); i * 2; end\n\n  def test_1\n    assert_equal(4, #{line})\n  end\n\n", @method.text)
  end

  def test_assertion_illegal_input
    line = "badtext"
    @method << line
    assert_nil @method.assertion(0)
  end

  def test_text
    @method << "1 + 1"
    assert_equal "  def test_1\n    assert_equal(2, 1 + 1)\n  end\n\n", @method.text
  end

  def test_text_variable_assignment_only
    line = "a = 1"
    @method << line
    assert_equal "  def test_1\n    #{line}\n  end\n\n", @method.text
  end

  def test_extract_definitions_class_multiline_empty
    line = "class MyClass"
    line2 = "end"
    line3 = "MyClass.new"
    @method << line
    @method << line2
    @method << line3
    assert_equal "  #{line}\n  #{line2}\n\n  def test_1\n    assert_not_equal((#{line3}), #{line3})\n  end\n\n", @method.text
  end

  def test_extract_definitions_class_with_method
    @method << "class MyClass"
    @method << "def name"
    @method << "\"classy\""
    @method << "end"
    @method << "end"
    @method << "MyClass.new.name"
    assert_equal "  class MyClass\n    def name\n      \"classy\"\n    end\n  end\n\n  def test_1\n    assert_equal(\"classy\", MyClass.new.name)\n  end\n\n", @method.text
  end

  def test_text_bad_input_constant
    @method << "BADCONSTANT"
    assert_nil @method.text
  end
  # non-project tests (scratchpad)

  def test_eval_scope
    value = eval "a = []\na << 1", Proc.new {}.binding
    assert_equal([1], value)
    assert_equal([1,1], eval("a << 1", Proc.new {}.binding))
  end

end