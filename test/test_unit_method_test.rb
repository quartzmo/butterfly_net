require "test/unit"
require "../lib/test_unit_method"

class TestUnitMethodTest < Test::Unit::TestCase

  def test_assigns_variable_true
     assert TestUnitMethod.new.assigns_variable? "a = 1"
  end

  def test_assigns_variable_false
     assert !TestUnitMethod.new.assigns_variable?("a + 1")
  end

end