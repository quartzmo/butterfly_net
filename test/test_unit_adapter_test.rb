require "test/unit"
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), File.join("..", "lib"))
require "butterfly_net/test_unit_method"
require "butterfly_net/test_unit_adapter"

class TestUnitAdapterTest < Test::Unit::TestCase
  include ButterflyNet
  
  def setup
    @adapter = TestUnitAdapter.new
  end

  def teardown
    File.delete 'temp_test.rb' if File.exists? 'temp_test.rb' # delete old in test, since impl should append, not overwrite
  end

  def test_expression_eval
    # assert eval("assert_equal(2, 1 + 1)")    todo figure out how to eval assertions here
  end

  def test_test_methods_single
    @adapter.add_command("1 + 1")
    expected = "def test_1\n    assert_equal(2, 1 + 1)\n  end"
    @adapter.test_methods
    assert_equal expected, @adapter.test_methods.first
  end

  def test_test_methods_2_assertions_1_method
    @adapter.add_command("1 + 1")
    @adapter.add_command("1 + 2")
    expected = "def test_1\n    assert_equal(2, 1 + 1)\n    assert_equal(3, 1 + 2)\n  end"
    @adapter.test_methods
    assert_equal expected, @adapter.test_methods.last
  end

  def test_test_methods_variable_in_assertion
    @adapter.add_command("a = 1")
    @adapter.add_command("a + 2")
    expected = "def test_1\n    a = 1\n    assert_equal(3, a + 2)\n  end"
    @adapter.test_methods
    assert_equal expected, @adapter.test_methods.last
  end

  def test_test_methods_numbering
    @adapter.add_command("1 + 1")
    @adapter.close_assertion_set
    @adapter.add_command("1 + 2")
    expected = "def test_2\n    assert_equal(3, 1 + 2)\n  end"
    @adapter.test_methods
    assert_equal expected, @adapter.test_methods.last
  end
  
  def test_create_file
    @adapter.add_command("1 + 1")
    expected  = <<-EOF
require "test/unit"

class TempTest < Test::Unit::TestCase

  def test_1
    assert_equal(2, 1 + 1)
  end

end
    EOF
    @adapter.create_file('temp_test.rb')
    assert_equal expected, File.open('temp_test.rb').readlines.join('')
  end

end