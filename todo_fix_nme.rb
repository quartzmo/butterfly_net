require "test/unit"

# IRB test capture courtesy of butterfly_net (butterflynet.org)
class MyTest < Test::Unit::TestCase

  def test_1
    assert_nil(class Miao
def say
"hi"
end
end
)
    # Miao.say   # NoMethodError: undefined method `say' for Miao:Class
    assert_equal("hi", Miao.new.say)
  end

end
  # definitions
class Miao
  def say
    "hi"
  end
end

