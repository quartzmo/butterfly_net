module ButterflyNet
  class TestUnitAdapter

    def header_text
      "require \"test/unit\"\n\n# IRB test capture courtesy of butterfly_net (butterflynet.org)\nclass MyTest < Test::Unit::TestCase\n\n"
    end

    def footer_text
      'end'
    end

    def test_method
      TestUnitMethod.new
    end

  end
end