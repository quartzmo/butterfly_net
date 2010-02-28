module ButterflyNet
  class TestUnitMethod

    attr_accessor :name
    attr_reader :definitions, :lines

    def initialize
      @commands = []       # todo: merge these 2 arrays in to single array of 2element pairs
      @lines = []
      @definitions = Definitions.new
    end

    def <<(line)
      unless @definitions << line
        begin
          code = @definitions.to_s + @commands.join("\n") + "\n" + line
          retval = eval code
          @commands << line    # todo replace def handling below with definitions (work in progress)
          @lines << final_line_string(line, retval)
        rescue Exception
          @commands << "# #{line}   # butterfly_net: Could not evaluate."
          @lines << "  # #{line}   # butterfly_net: Could not evaluate."
        end
      end
      self
    end

    def empty?
      @commands.empty?
    end

    def name=(name)
      name = underscore(name)
      @name = name =~ /^\s*test_/ ? name : "test_#{name}"
    end

    def self.assignment_or_require?(line)  # todo: extract to line class
      line =~ /require\s*['|"]\w+['|"]|[^=<>!*%\/+-\\|&]=[^=~]/
    end

    def text
      lines_string = @lines.inject("") {|result, e| result += "    #{e}\n" if e; result}
      lines_string.empty? ? nil : "#{@definitions.to_s}  def #{@name}\n#{lines_string}  end\n\n"
    end

    def final_line_string(current_line, retval)
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
        "assert_not_nil(#{current_line})"    # todo assert_not_nil in some cases?
      end
    end

    def instances_equal_by_value?(instance)
      instance == instance.dup rescue true  # assume anything like Fixnum that can't be dup'd is a value type...
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