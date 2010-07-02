require "test/unit"
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), File.join("..", "lib"))
require "butterfly_net/file_writer"
require "butterfly_net/definitions"
require "butterfly_net/test_unit_method"
require "butterfly_net/test_unit_adapter"
require "butterfly_net/rails_test_unit_adapter"
require "butterfly_net/test_case"

class TestCaseTest < Test::Unit::TestCase
  include ButterflyNet
  
  def setup
    @test_case = TestCase.new('temp_test.rb')
  end

  def teardown
    File.delete 'temp_test.rb' if File.exists? 'temp_test.rb' # delete old in test, since impl should append, not overwrite
  end

  def test_expression_eval
    # assert eval("assert_equal(2, 1 + 1)")    todo figure out how to eval assertions here
  end

  def test_test_methods_single
    @test_case.add_command("1 + 1", 2)
    expected = "  def test_1\n    assert_equal(2, 1 + 1)\n  end\n\n"
    assert_equal expected, @test_case.test_methods.first
  end

  def test_test_methods_2_assertions_1_method
    @test_case.add_command("1 + 1", 2)
    @test_case.add_command("1 + 2", 3)
    expected = "  def test_1\n    assert_equal(2, 1 + 1)\n    assert_equal(3, 1 + 2)\n  end\n\n"
    assert_equal expected, @test_case.test_methods.last
  end

  def test_test_methods_variable_in_assertion
    @test_case.add_command("a = 1", 1)
    @test_case.add_command("a + 2", 3)
    expected = "  def test_1\n    a = 1\n    assert_equal(3, a + 2)\n  end\n\n"
    assert_equal expected, @test_case.test_methods.last
  end

  def test_test_methods_require
    @test_case.add_command("require 'bigdecimal'", true)
    @test_case.add_command("BigDecimal(\"1.0\") - 0.5", 0.5)    # result class really is Float
    expected = "  def test_1\n    require 'bigdecimal'\n    assert_equal(0.5, BigDecimal(\"1.0\") - 0.5)\n  end\n\n"
    assert_equal expected, @test_case.test_methods.last
  end

  def test_test_methods_numbering_first_method
    @test_case.add_command("1 + 1", 2)
    @test_case.close_assertion_set
    @test_case.add_command("1 + 2", 3)
    assert_equal "  def test_1\n    assert_equal(2, 1 + 1)\n  end\n\n", @test_case.test_methods.first
  end       

  def test_test_methods_numbering_second_method
    @test_case.add_command("1 + 1", 2)
    @test_case.close_assertion_set
    @test_case.add_command("1 + 2", 3)
    assert_equal "  def test_2\n    assert_equal(3, 1 + 2)\n  end\n\n", @test_case.test_methods.last
  end

  def test_test_methods_naming
    @test_case.add_command("1 + 1", 2)
    @test_case.close_assertion_set 'test_one_plus_one'
    assert_equal "  def test_one_plus_one\n    assert_equal(2, 1 + 1)\n  end\n\n", @test_case.test_methods.first
  end

  def test_test_methods_bad_input
    @test_case.add_command("BADCOMMAND", nil, NameError.new("exception message"))
    @test_case.close_assertion_set
    assert_equal "  def test_1\n    # BADCOMMAND   # NameError: exception message\n  end\n\n", @test_case.test_methods.first
  end

  def test_empty_false
    @test_case.add_command("1 + 1", 2)
    assert !@test_case.empty?
  end
  
  def test_create_file
    @test_case.add_command("1 + 1", 2)
    expected  = <<-EOF
require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_equal(2, 1 + 1)
  end

end
    EOF
    @test_case.create_file('temp_test.rb')   # todo: write to memory instead of file...
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end

  def test_create_file_with_2_methods
    @test_case.add_command("1 + 1", 2)
    @test_case.close_assertion_set('first')
    @test_case.add_command("1 + 2", 3)
    expected  = <<-EOF
require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_equal(2, 1 + 1)
  end

  def test_2
    assert_equal(3, 1 + 2)
  end

end
    EOF
    @test_case.create_file('temp_test.rb')   # todo: write to memory instead of file...
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end

  def test_create_file_single_test_method_two_lines
    @test_case.add_command("a = 1", 1)
    @test_case.add_command("a + 2", 3)
    expected  = <<-EOF
require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    a = 1
    assert_equal(3, a + 2)
  end

end
    EOF
    @test_case.create_file('temp_test.rb')   # todo: write to memory instead of file...
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end

  def test_create_file_definitions
    @test_case.add_command("class Mine\nend", nil)
    @test_case.add_command("Mine.new.class.to_s", "Mine")
    expected  = <<-EOF
require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_equal("Mine", Mine.new.class.to_s)
  end

end

# definitions
class Mine
end

    EOF
    @test_case.create_file('temp_test.rb')   # todo: write to memory instead of file...
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end



  def test_create_file_def_method_single_inline
    @test_case.add_command("def timestwo(i); i * 2; end", nil)
    @test_case.add_command("timestwo(4)", 8)
    expected = <<-EOF
require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_equal(8, timestwo(4))
  end

end

# definitions
def timestwo(i); i * 2; end

    EOF
    @test_case.create_file('temp_test.rb')   # todo: write to memory instead of file...
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end

  def test_create_file_def_methods_two_inline
    @test_case.add_command("def timestwo(i); i * 2; end", nil)
    @test_case.add_command("def timesfour(i); timestwo(i) * timestwo(i); end", nil)
    @test_case.add_command("timestwo(1)", 2)
    @test_case.add_command("timesfour(1)", 4)
    expected = <<-EOF
require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_equal(2, timestwo(1))
    assert_equal(4, timesfour(1))
  end

end

# definitions
def timestwo(i); i * 2; end

def timesfour(i); timestwo(i) * timestwo(i); end

    EOF
    @test_case.create_file('temp_test.rb')   # todo: write to memory instead of file...
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end

end