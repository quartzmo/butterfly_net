module ButterflyNet
  class TestUnitAdapter

    attr_reader :assertion_sets

    def initialize
      @assertion_sets = []
    end

    def add_command(line)
      @assertion_sets << TestUnitMethod.new unless @assertion_sets.last
      @assertion_sets.last << line
    end

    def close_assertion_set
      @assertion_sets << TestUnitMethod.new
    end

    def create_file(filename)
      return nil if @assertion_sets.empty?

      #todo detect existing file, and delete last 'end' line
      file = File.open(filename, 'a+')  # starts at end of file if file exists

      if defined? ActiveSupport::TestCase # rails  # todo support earlier versions of rails
        file.puts "require \"test_helper\"\n\nclass TempTest < ActiveSupport::TestCase"
      else
        file.puts "require \"test/unit\"\n\nclass TempTest < Test::Unit::TestCase"
      end

      test_methods.each do |test_method|
        file.puts "\n  #{test_method}"
      end

    ensure
      if file # todo: closing is always good, but prevent writing partial data in case of exception
        file.puts "\nend"
        file.close
      end

    end

    def test_methods
      method_strings = []
      @assertion_sets.each_with_index do |assertions, i|


        method_strings << assertions.text(i + 1)
      end
      method_strings
    end

  end
end