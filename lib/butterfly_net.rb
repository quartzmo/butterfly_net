require 'test_unit_method'
require 'test_unit_adapter'




class ButterflyNetFile

  attr_writer :start_index, :end_index

  def initialize(file_name)
    @file_name = file_name
  end

  def new_assertion_set

  end


  def close

    lines = Readline::HISTORY.to_a
    @end_index ||= Readline::HISTORY.size - 3 # in case of no call to 'bn_close'
    return if @end_index < 0 # no commands other than open
    lines = lines[@start_index..@end_index]
    puts "Readline::HISTORY.to_a[#{@start_index}..#{@end_index}]"
    puts "lines.size=#{lines.size}"

    adapter = TestUnitAdapter.new

    lines.each do |line|
      puts line
      adapter.add_command(line)
    end

    adapter.create_file(@file_name)

  rescue Exception => msg
    puts "butterfly_net:  Error generating tests: #{msg}"
  end

end

#
# Command shortcuts:
#
# bo - open butterfly net
# bc - close butterfly net
# btc(name) - start new test case (file), with optional name
# bas - close current test method, and open another
# bsu - add preceding line to setup method
# btd - add preceding line to teardown method
#
module ButterflyNet

  def bn_open
    raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    start_index = Readline::HISTORY.empty? ? 0 : (Readline::HISTORY.size - 1)
    @file = ButterflyNetFile.new('irb_tests.rb')
    @file.start_index = start_index
    Kernel.at_exit { @file.close if @file }
    "Started at Readline::HISTORY ##{start_index}"
  end

  def bn_close
    raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    return "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session" unless @file
    end_index = Readline::HISTORY.size - 3
    @file.end_index = end_index
    @file.close
    @file = nil
    "Ended at Readline::HISTORY ##{end_index}"
  end

  def bn_new_assertion_set(name)
    return "'name' argument is required. No action." unless name
    @file.close
    @file = ButterflyNetFile.new(name)
  end


  alias :bn :bn_open
  alias :bnc :bn_close
  alias :bns :bn_new_assertion_set

end

include ButterflyNet