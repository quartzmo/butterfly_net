require 'test_unit_method'
require 'test_unit_adapter'




class HistoryWriter

  attr_writer :start_index, :end_index

  def initialize

  end

  def close_assertion_set

  end


  def write_test_from_history

    lines = Readline::HISTORY.to_a
    @end_index ||= Readline::HISTORY.size - 3 # in case of no call to 'bn_close'
    lines = lines[@start_index..@end_index]
    puts "Readline::HISTORY.to_a[#{@start_index}..#{@end_index}]"
    puts "lines.size=#{lines.size}"

    adapter = TestUnitAdapter.new

    lines.each do |line|
      puts line
      adapter.add_command(line)
    end

    adapter.create_file('irb_tests.rb')

  rescue Exception => msg
    puts "butterfly_net:  Error generating tests: #{msg}"
  end

end

#
# Command shortcuts:
#
# o - open butterfly net
# c - close butterfly net
# tc(name) - start new test case (file), with optional name
# m - close current test method, and open another
# sm - add preceding line to setup method
# sm - add preceding line to teardown method
#
module ButterflyNet

  def bn_open
    raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    start_index = Readline::HISTORY.empty? ? 0 : (Readline::HISTORY.size - 1)
    @history_writer = HistoryWriter.new    
    @history_writer.start_index = start_index
    "Started at Readline::HISTORY ##{start_index}"
    Kernel.at_exit { @history_writer.write_test_from_history if @history_writer }
  end

  def bn_close
    raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    raise "butterfly_net: First invoke 'bn_open' to begin a session" unless @history_writer
    end_index = Readline::HISTORY.size - 3
    @history_writer.end_index = end_index
    "Ended at Readline::HISTORY ##{end_index}"
    @history_writer.write_test_from_history
    @history_writer = nil
  end

  def bn_new_assertion_set
    @history_writer.close_assertion_set
  end


  alias :o :bn_open
  alias :c :bn_close
  alias :m :bn_new_assertion_set

end

include ButterflyNet