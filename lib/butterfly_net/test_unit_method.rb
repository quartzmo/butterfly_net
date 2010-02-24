module ButterflyNet
  class TestUnitMethod

    attr_accessor :name

    def initialize
      @definitions = []
      @commands = []
    end

    def <<(line)
      @commands << line
    end

    def name=(name)
      name = underscore(name)
      @name = name =~ /^\s*test_/ ? name : "test_#{name}"
    end

    def self.assignment_or_require?(line)  # todo: extract to line class
      line =~ /require\s*['|"]\w+['|"]|[^=<>!*%\/+-\\|&]=[^=~]/
    end

    def self.start_def?(line)  # todo: extract to line class
      line =~ /^\s*def\s+|^\s*class\s+|^\s*module\s+/
    end

    def self.end_def?(line)  # todo: extract to line class
      line =~ /end\s*$/
    end

    def text
      purge_bad_commands
      before_test_method = ""
      lines_string = ""
      definition_nesting_level = 0
      @commands.each_with_index do |current_line, i|
        if TestUnitMethod.start_def?(current_line) and TestUnitMethod.end_def?(current_line)
          before_test_method += "  #{current_line}\n\n"
        elsif TestUnitMethod.start_def?(current_line)
          definition_nesting_level += 1
          before_test_method += "  #{current_line}\n\n"
        elsif TestUnitMethod.end_def?(current_line)
          definition_nesting_level -= 1
          before_test_method += "  #{current_line}\n\n"
        elsif definition_nesting_level == 0
          text = assertion(i)
          lines_string += "    #{text}\n" if text
        else
          indent = "  " * (definition_nesting_level - 1)
          before_test_method += "#{indent}#{current_line}\n\n"          
        end
      end
      before_test_method += "  "
      lines_string.empty? ? nil : "#{before_test_method}def #{@name}\n#{lines_string}  end"
    end

    def assertion(current_i)

      current_line = @commands[current_i]
      commands = current_line
      start_i = current_i

      begin
        retval = eval commands
      rescue Exception
        start_i -= 1
        commands = @commands[start_i..current_i].join("\n")

        if start_i < 0
          return nil    # give up, can't go further back
        else
          retry
        end
      end
      if TestUnitMethod.assignment_or_require?(current_line)
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

    def purge_bad_commands
      begin
        commands = ""
        index = 0
        definition_nesting_level = 0
        @commands.each_with_index do |current_line, i|
          index = i
          commands += current_line + "\n"
          if TestUnitMethod.start_def?(current_line) and TestUnitMethod.end_def?(current_line)
            #let it ride
          elsif TestUnitMethod.start_def?(current_line)
            definition_nesting_level += 1
          elsif TestUnitMethod.end_def?(current_line)
            definition_nesting_level -= 1
          elsif definition_nesting_level == 0
            eval commands  #todo write test breaking assumption that definitions are valid code, and impl separate eval's for definitions
          end
        end
        nil
      rescue Exception
        # delete offender and start again from the beginning
        @commands.delete_at index      # todo: test if string equality is safe for delete()
        retry
      end
    end

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