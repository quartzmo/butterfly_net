class TestUnitAdapter

  attr_reader :assertion_sets

  def add_command(line)
    @assertion_sets ||= []
    @assertion_sets << TestUnitMethod.new unless @assertion_sets.last
    @assertion_sets.last << line
  end

  def close_assertion_set
    @assertion_sets << TestUnitMethod.new
  end

  def create_file(filename)
    file = File.open(filename, 'w+')
    file.puts "require \"test/unit\"\n\nclass TempTest < Test::Unit::TestCase"

    test_methods.each do |test_method|
      file.puts "\n  #{test_method}"
    end

    file.puts "\nend"
  ensure
    file.close if file
  end

  def test_methods
    method_strings = []
    @assertion_sets.each_with_index do |assertions, i|

      
      method_strings << assertions.text(i + 1)
    end
    method_strings
  end

end