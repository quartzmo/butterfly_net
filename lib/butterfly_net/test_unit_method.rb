module ButterflyNet
  class TestUnitMethod

    attr_accessor :name

    def initialize
      @commands = []
    end

    def <<(line)
      @commands << line
    end

    def name=(name)
      @name = underscore(name)
    end

    def self.simple_assignment_only?(line)  # todo: extract to line class
      line =~ /[^=<>!*%\/+-\\|&]=[^=~]/
    end

    def self.assertion(expected, line)     # todo: extract to assertion class
      if expected && simple_assignment_only?(line)
        line
      elsif expected && expected == line # type not supported, assume object inequality
        "assert_not_equal((#{expected}), #{line})"
      elsif expected == "true" # use simple assert() for true boolean expressions
        "assert(#{line})"
      elsif expected
        "assert_equal(#{expected}, #{line})"
      else
        nil
      end
    end

    def text_from_expression(line, i)
      expected_assertion(i)
    end

    def text(position)
      lines_string = ""
      @commands.each_with_index do |line, i|
        text = text_from_expression(line, i)
        lines_string += "    #{text}\n" if text
      end
      method_name = @name ? (@name =~ /^test_/ ? @name : "test_#{@name}") : "test_#{position}"
      lines_string.empty? ? nil : "def #{method_name}\n#{lines_string}  end"
    end

    def expected_assertion(current_i)

      current_line = @commands[current_i]
      commands = current_line
      start_i = current_i

      begin
        retval = eval commands
      rescue
        start_i -= 1
        commands = @commands[start_i..current_i].join("\n")

        if start_i < 0
          puts "failure evaluating: eval[#{start_i}..#{current_i}] : #{commands}\n"
          return nil
        else
          retry
        end
      end
      if retval && TestUnitMethod.simple_assignment_only?(current_line)
        current_line

      elsif instances_equal_by_value?(retval) # expression result supports value equality

        if retval == true # use simple assert() for true boolean expressions
          "assert(#{current_line})"
        elsif retval.nil?
          "assert_nil(#{current_line})"
        else
          "assert_equal(#{retval.inspect}, #{current_line})"
        end

      else

        # any other sort of object is handled as a not equal assertion
        "assert_not_equal((#{current_line}), #{current_line})"
      end

    end

    def instances_equal_by_value?(instance)
      instance == instance.dup rescue true  # can't dup Fixnum, et al...
    end

    private

    # Adapted from ActiveSupport Inflector
    def underscore(name)
      name.to_s.strip.
              gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
              gsub(/([a-z\d])([A-Z])/, '\1_\2').
              tr("-", "_").
              tr(" ", "_").
              downcase
    end



  end
end