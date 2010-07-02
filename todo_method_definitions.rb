require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_equal("Mipa", Mipa.new.class.to_s)
  end


# definitions
class Mipa
  def say
    "hellooo"
  end
end

  def test_2
    assert_equal(2, 1+1)
  end

  def test_3
  end

end
