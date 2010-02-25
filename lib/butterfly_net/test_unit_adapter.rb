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

    def close_assertion_set(method_name = nil)
      @assertion_sets.last.name = (method_name ? method_name : @assertion_sets.size)
      @assertion_sets << TestUnitMethod.new
    end

    def empty?
      @assertion_sets.empty?
    end

    def body
      body = ""
      test_methods.each do |test_method|
        body += "#{test_method}\n\n"
      end
      body
    end

    def create_file(filename)
      bodytext = body

      return false if empty? || bodytext.empty?
      begin
        #todo detect existing file, and delete last 'end' line
        file = File.open(filename, 'a+')  # starts at end of file if file exists

        if defined? ActiveSupport::TestCase # rails  # todo support earlier versions of rails
          file.puts "require \"test_helper\"\n\n# script/console test capture courtesy of butterfly_net (butterflynet.org)\nclass MyTest < ActiveSupport::TestCase\n\n"
        else
          file.puts "require \"test/unit\"\n\n# IRB test capture courtesy of butterfly_net (butterflynet.org)\nclass MyTest < Test::Unit::TestCase\n\n"
        end

        file.puts bodytext
        
        true
      ensure
        if file # todo: closing is always good, but prevent writing partial data in case of exception
          file.puts "end"
          file.close
        end
      end
    end

    def test_methods
      @assertion_sets.last.name = @assertion_sets.size unless @assertion_sets.last.name # assign the default, numbered name; done here for testing
      @assertion_sets.collect {|i| i.text }.compact
    end

  end
end