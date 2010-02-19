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
    expected = expected(i)
    if expected && assigns_variable?(line)
      line
    elsif expected && expected == line # type not supported, assume object inequality
      "assert_not_equal((#{expected}), #{line})" 
    elsif expected
      "assert_equal(#{expected}, #{line})"
    else
      nil
    end
  end

  def text(method_name)
    method_string = "def test_#{method_name}\n"
    @lines.each_with_index do |line, i|
      text = text_from_expression(line, i)
      method_string += "    #{text}\n" if text
    end
    method_string += "  end"
  end

  def expected(current_i)

    commands = @lines[current_i]
    start_i = current_i

    begin
     retval = eval commands
    rescue
      start_i -= 1

      commands = @lines[start_i..current_i].join("\n")
      if start_i < 0
        puts "failure evaluating:\n#{commands}"
        return nil
      else
        retry
      end
    end

    # todo: continue to implement cases for all possible types, or something better..
    if retval.nil?
      "nil"
    elsif retval.is_a? String
      "\"#{retval}\""
    elsif retval.is_a? Fixnum
      retval
    else
      @lines[current_i] # return any other sort of object for now, for a not equal assertion
    end

  end

end