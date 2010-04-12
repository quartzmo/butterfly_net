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
        #begin
          #code = @definitions.to_s + @commands.join("\n") + "\n" + line
          #retval = eval code
          #@commands << line    # todo replace def handling below with definitions (work in progress)
          @lines << final_line_string(line, retval)
        #rescue Exception
          #@commands << "# #{line}   # butterfly_net: Could not evaluate."
        #  @lines << "# #{line}   # butterfly_net: Could not evaluate."
        #end
      end
      self
    end

    def empty?
      @lines.empty?
    end

    def name=(name)
      name = underscore(name)
      @name = name =~ /^\s*test_/ ? name : "test_#{name}"
    end

    def self.assignment_or_require?(line)  # todo: extract to line class
      line =~ /require\s*['|"]\w+['|"]|[^=<>!*%\/+-\\|&]=[^=~]/
    end

    def text
      @name = "test_1"
      lines_string= @lines.map{|line| line[1]%[line[0]?line[2]:line[3],line[4],line[5]]}.join("\n")
      #lines_string = @lines.compact.inject("") {|result, e| result += "    #{e}\n" }
      lines_string.empty? ? nil : "#{@definitions}  def #{@name}\n#{lines_string}  end\n\n"
    end
    def oops

      @lines[-1][0]=false
    end

    def write_assertion(fmt, positive, negative, expr,value)
      if @definitions << [true,"%s",expr]
      elsif TestUnitMethod.assignment_or_require?(expr)
        @lines << [true,"%s",expr]
      else


          @lines << [true,fmt,positive,negative,expr,value]
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