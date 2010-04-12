module ButterflyNet
  class Definitions

    attr_reader :lines

    def initialize
      @nesting_level = 0
      @lines = []
    end

    def empty?
      @lines.empty?
    end

    def self.start_def?(line)  # todo: extract to line class
      line =~ /\A\s*def\s+|\A\s*class\s+|\A\s*module\s+/
    end

    def self.end_def?(line)  # todo: extract to line class
      line =~ /end\s*$/
    end

    def <<(line)        # change method name, since doesn't return self for chaining per convention
      if Definitions.start_def?(line) and Definitions.end_def?(line)
        @lines << "  #{("  " * @nesting_level)}#{line}\n\n"
      elsif Definitions.start_def?(line)
        @nesting_level += 1
        @lines << "#{("  " * @nesting_level)}#{line}\n"
      elsif @nesting_level > 0
        @nesting_level -= 1 if Definitions.end_def?(line)
        @lines << "  #{("  " * @nesting_level)}#{line}\n#{ @nesting_level == 0 ? "\n" : ""}"
      else
        false
      end
    end

    def to_s
      @lines.join
    end
    
  end
end