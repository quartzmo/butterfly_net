module ButterflyNet
  class RailsTestUnitAdapter < TestUnitAdapter

    def header_text
      "require \"test_helper\"\n\n# script/console test capture courtesy of butterfly_net (butterflynet.org)\nclass MyTest < ActiveSupport::TestCase\n\n"
    end

  end
end