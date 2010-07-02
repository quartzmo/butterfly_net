module ButterflyNet
  class TestCase

    attr_reader :assertion_sets

    def initialize(filename)
      rails = defined? ActiveSupport::TestCase  # todo support earlier versions of rails?
      @adapter = rails ? RailsTestUnitAdapter.new : TestUnitAdapter.new
      @assertion_sets = [@adapter.test_method]
      @file = File.open(filename, 'a') ; @file.write(@adapter.header_text); @file.flush
      @count = 1
      @method = @adapter.test_method
      @method.name = @count
      @file.write(@method.opening_text); @file.flush
    end

    def add_command(line, result, exception=nil)
      @assertion_sets.last.write_expression line, result, exception
      last_line = @method.write_expression(line, result, exception).lines.last
      @file.write("    #{last_line}\n") if last_line
      @file.flush
   #   @file_writer.write(@adapter.test_method.write_expression(line, result, exception).text)
    end

    # user provides name at closing
    def close_assertion_set(method_name = nil)
      @file.write(@method.closing_text);
      @file.write("\n# definitions\n#{@method.definitions}") unless @method.definitions.empty?      
      @count += 1
      @method = @adapter.test_method
      @method.name = @count
      @file.write(@method.opening_text); @file.flush
      @assertion_sets.last.name = (method_name ? method_name : @assertion_sets.size)
      @assertion_sets << @adapter.test_method
    end

    # true if ALL are empty
    def empty?
      @assertion_sets.inject(true) {|result,e| result = (result and e.empty?); result}
    end

    def create_file(filename)
      @file.write(@method.closing_text);
      @file.write(@adapter.footer_text + "\n")
      @file.write("\n# definitions\n#{@method.definitions}") unless @method.definitions.empty?
      @file.close
    end

    def test_methods
      @assertion_sets.last.name = @assertion_sets.size unless @assertion_sets.last.name # assign the default, numbered name; done here for testing
      @assertion_sets.collect {|i| i.text }.compact
    end

  end
end