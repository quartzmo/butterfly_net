module ButterflyNet
  class TestCase

    attr_reader :assertion_sets

    def initialize
      rails = defined? ActiveSupport::TestCase  # todo support earlier versions of rails?
      @adapter = rails ? RailsTestUnitAdapter.new : TestUnitAdapter.new
      @assertion_sets = [@adapter.test_method]
    end

    def add_command(line)
      @assertion_sets.last << line
    end

    # user provides name at closing
    def close_assertion_set(method_name = nil)
      @assertion_sets.last.name = (method_name ? method_name : @assertion_sets.size)
      @assertion_sets << @adapter.test_method
    end

    # true if ALL are empty
    def empty?
      @assertion_sets.inject(true) {|result,e| result = (result and e.empty?); result}
    end

    def create_file(filename)
      bodytext = generate_bodytext
      return false if empty? || bodytext.empty?
      FileWriter.new(filename).create_file(@adapter.header_text + bodytext + @adapter.footer_text)
    end

    def test_methods
      @assertion_sets.last.name = @assertion_sets.size unless @assertion_sets.last.name # assign the default, numbered name; done here for testing
      @assertion_sets.collect {|i| i.text }.compact
    end

    def generate_bodytext
      test_methods.inject("") { |result,e|result += e; result }
    end

  end
end