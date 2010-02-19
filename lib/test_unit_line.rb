class TestUnitLine

  def initialize(expected, line)
    @text = assertion(expected, line)
  end

  def assigns_variable?(line)  # todo: extract to line class
    line =~ /[^=]=[^=]/
  end

  def assertion(expected, line)     # todo: extract to assertion class
    if expected && assigns_variable?(line)
      line
    elsif expected && expected == line # type not supported, assume object inequality
      "assert_not_equal((#{expected}), #{line})"
    elsif expected == "true" # use simple assert() for true boolean expressions
      "assert(#{line})"
    elsif expected
      "assert_equal(#{expected}, #{line})"
    else
      nil    #todo: relocate elsewhere
    end
  end

  def to_s
    @text
  end

end