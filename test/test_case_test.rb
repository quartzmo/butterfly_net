require "test/unit"
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), File.join("..", "lib"))
require "butterfly_net/file_writer"
require "butterfly_net/test_unit_method"
require "butterfly_net/test_unit_adapter"
require "butterfly_net/rails_test_unit_adapter"
require "butterfly_net/test_case"

class TestCaseTest < Test::Unit::TestCase
  include ButterflyNet
  
  def setup
    @adapter = TestCase.new
  end

  def teardown
    File.delete 'temp_test.rb' if File.exists? 'temp_test.rb' # delete old in test, since impl should append, not overwrite
  end

  def test_expression_eval
    # assert eval("assert_equal(2, 1 + 1)")    todo figure out how to eval assertions here
  end

  def test_test_methods_single
    @adapter.add_command("1 + 1")
    expected = "  def test_1\n    assert_equal(2, 1 + 1)\n  end\n\n"
    assert_equal expected, @adapter.test_methods.first
  end

  def test_test_methods_2_assertions_1_method
    @adapter.add_command("1 + 1")
    @adapter.add_command("1 + 2")
    expected = "  def test_1\n    assert_equal(2, 1 + 1)\n    assert_equal(3, 1 + 2)\n  end\n\n"
    assert_equal expected, @adapter.test_methods.last
  end

  def test_test_methods_variable_in_assertion
    @adapter.add_command("a = 1")
    @adapter.add_command("a + 2")
    expected = "  def test_1\n    a = 1\n    assert_equal(3, a + 2)\n  end\n\n"
    assert_equal expected, @adapter.test_methods.last
  end

  def test_test_methods_require
    @adapter.add_command("require 'bigdecimal'")
    @adapter.add_command("BigDecimal(\"1.0\") - 0.5")
    expected = "  def test_1\n    require 'bigdecimal'\n    assert_equal(0.5, BigDecimal(\"1.0\") - 0.5)\n  end\n\n"
    assert_equal expected, @adapter.test_methods.last
  end

  def test_test_methods_def_method_single_inline
    @adapter.add_command("def timestwo(i); i * 2; end")
    @adapter.add_command("timestwo(4)")
    expected = <<-EOF
  def timestwo(i); i * 2; end

  def test_1
    assert_equal(8, timestwo(4))
  end

    EOF
    assert_equal expected, @adapter.generate_bodytext
  end

  def test_test_methods_def_methods_two_inline
    @adapter.add_command("def timestwo(i); i * 2; end")
    @adapter.add_command("def timesfour(i); timestwo(i) * timestwo(i); end")
    @adapter.add_command("timestwo(1)")
    @adapter.add_command("timesfour(1)")
    expected = <<-EOF
  def timestwo(i); i * 2; end

  def timesfour(i); timestwo(i) * timestwo(i); end

  def test_1
    assert_equal(2, timestwo(1))
    assert_equal(4, timesfour(1))
  end

    EOF
    assert_equal expected, @adapter.generate_bodytext
  end

  def test_test_methods_numbering_first_method
    @adapter.add_command("1 + 1")
    @adapter.close_assertion_set
    @adapter.add_command("1 + 2")
    assert_equal "  def test_1\n    assert_equal(2, 1 + 1)\n  end\n\n", @adapter.test_methods.first
  end       

  def test_test_methods_numbering_second_method
    @adapter.add_command("1 + 1")
    @adapter.close_assertion_set
    @adapter.add_command("1 + 2")
    assert_equal "  def test_2\n    assert_equal(3, 1 + 2)\n  end\n\n", @adapter.test_methods.last
  end

  def test_test_methods_naming
    @adapter.add_command("1 + 1")
    @adapter.close_assertion_set 'test_one_plus_one'
    assert_equal "  def test_one_plus_one\n    assert_equal(2, 1 + 1)\n  end\n\n", @adapter.test_methods.first
  end

  def test_test_methods_bad_input
    @adapter.add_command("BADCOMMAND")
    @adapter.close_assertion_set
    assert_nil @adapter.test_methods.first
  end
  
  def test_create_file
    @adapter.add_command("1 + 1")
    expected  = <<-EOF
require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_equal(2, 1 + 1)
  end

end
    EOF
    @adapter.create_file('temp_test.rb')   # todo: write to memory instead of file...
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end

end