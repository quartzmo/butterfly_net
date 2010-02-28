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
      line =~ /^\s*def\s+|^\s*class\s+|^\s*module\s+/
    end

    def self.end_def?(line)  # todo: extract to line class
      line =~ /end\s*$/
    end

    def <<(line)
      if Definitions.start_def?(line) and Definitions.end_def?(line)
        @lines << "  #{("  " * @nesting_level)}#{line}\n\n"
      elsif Definitions.start_def?(line)
        @nesting_level += 1
        @lines << "#{("  " * @nesting_level)}#{line}\n"
      elsif Definitions.end_def?(line)
        @nesting_level -= 1
        @lines << "  #{("  " * @nesting_level)}#{line}\n#{ @nesting_level == 0 ? "\n" : ""}"
      elsif @nesting_level > 0
        @lines << "  #{("  " * @nesting_level)}#{line}\n"  unless @nesting_level == 0
      else
        false
      end
    end

    def to_s
      @lines.join
    end
    
  end
end