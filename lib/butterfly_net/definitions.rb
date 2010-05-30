module ButterflyNet
  class Definitions

    include RBeautify

    attr_reader :lines

    def initialize
      @nesting_level = 0
      @lines = []
    end

    def empty?
      @lines.empty?
    end

    def self.start_def?(line) # todo: extract to line class
      line =~ /^\s*def\s+|^\s*class\s+|^\s*module\s+/
    end

    def self.end_def?(line) # todo: extract to line class
      line =~ /end\s*$/
    end

    def <<(line)
     if Definitions.start_def?(line)
        formatted = RBeautify.beautify_string(line)
        @lines << formatted[0] + "\n"
        if formatted[1]
          false
        else
          true
        end
      else
        false
      end
    end

    def to_s
      @lines.join
    end

  end
end