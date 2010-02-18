class TestUnitMethod

  def initialize
    @lines = []
  end

  def <<(line)
    @lines << line
  end

  def assigns_variable?(line)
    line =~ /=/
  end

  def text_from_expression(line, i)
    assigns_variable?(line) ? line : "assert_equal(#{expected(i)}, #{line})"
  end

  def text(method_name)
    method_string = "def test_#{method_name}\n"
    @lines.each_with_index { |line, i| method_string += "    #{text_from_expression(line, i)}\n" }
    method_string += "  end"
  end

  def expected(current_i)
    commands = @lines[current_i]
    start_i = current_i
    begin
      eval commands
    rescue
      start_i -= 1
      commands = @lines[start_i..current_i].join("\n")
      retry
    end
  end

end