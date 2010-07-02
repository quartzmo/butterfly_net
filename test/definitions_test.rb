require "test/unit"
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), File.join("..", "lib"))
require "rbeautify"
require "butterfly_net/definitions"

class DefinitionsTest < Test::Unit::TestCase
  include ButterflyNet

  def setup
    @definitions = Definitions.new
  end


  def test_method_def_true_whitespace
    assert Definitions.start_def?(" def timestwo(i); i * 2; end ")
  end

  def test_class_def_true_whitespace
    assert Definitions.start_def?(" class MyClass; end ")
  end

  def test_class_def_true_whitespace
    assert Definitions.start_def?(" module MyModule; end ")
  end

  def test_method_def_false_variable
    assert !Definitions.start_def?("definite == true ")
  end


  def test_start_def_true_inline
    assert Definitions.start_def?(" def timestwo(i); i * 2; end ")
  end

  def test_end_def_true_inline
    assert Definitions.end_def?(" def timestwo(i); i * 2; end ")
  end

  def test_end_def_true_whitespace
    assert Definitions.end_def?(" end ")
  end

  def test_definitions_inline
    line = "def timestwo(i); i * 2; end"
    @definitions << line
    assert @definitions.lines.include?("def timestwo(i); i * 2; end\n\n")
  end

  def test_definitions_class_empty
    line = "class MyClass\nend"
    @definitions << line
    assert_equal(["class MyClass\nend\n\n"], @definitions.lines)
  end

  def test_to_s_method_inline
    @definitions << "def timestwo(i); i * 2; end"
    assert_equal("def timestwo(i); i * 2; end\n\n", @definitions.to_s)
  end

  def test_to_s_class_with_method
    @definitions << "class MyClass\ndef name\n\"classy\"\nend\nend"
    assert_equal "class MyClass\n  def name\n    \"classy\"\n  end\nend\n\n", @definitions.to_s
  end

# todo write tests breaking assumption that definitions are valid code, and impl separate eval's for definitions
#  def test_text_bad_input_constant
#    @definitions << "BADCONSTANT"
#    assert_equal "  # BADCONSTANT # NameError: uninitialized constant BADCONSTANT", @definitions.to_s
#  end

end