require 'test_unit_method'
require 'test_unit_adapter'




class ButterflyNetFile

  attr_accessor :start_index, :end_index
  attr_reader :file_name

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
    puts "butterfly_net: #{@file_name} closed at Readline::HISTORY ##{@end_index}"

    adapter = TestUnitAdapter.new

    lines.each do |line|
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
# bn  - open new Butterfly Net test case, with optional name
# bna - end existing assertion set (test method) and begin a new assertion set, with optional name
# bnc - close Butterfly Net test case, writing output file
# bns - add preceding line to setup method, instead of current assertion set           # todo
# bnt - add preceding line to teardown method, instead of current assertion set        # todo
#
module ButterflyNet

  def bn_open(file_name=nil)
    @file.close if @file
    raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    start_index = Readline::HISTORY.empty? ? 0 : (Readline::HISTORY.size - 1)
    file_name ||= "butterfly_net_#{Time.now.strftime("%Y%m%d%H%M%S")}.rb"
    file_name += ".rb" unless file_name =~ /.rb/
    @file = ButterflyNetFile.new(file_name)
    @file.start_index = start_index
    Kernel.at_exit { @file.close if @file; @file = nil }
    "butterfly_net: #{file_name} opened at Readline::HISTORY ##{start_index}"
  end

  def bn_close
    raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    return "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session" unless @file
    @file.close
    @file = nil
  end


  alias :bn :bn_open
  alias :bnc :bn_close

end

include ButterflyNet