module ButterflyNet
  class FileWriter

    attr_accessor :end_index
    attr_reader :start_index

    def initialize(file_name, start_index)
      @file_name = file_name
      @start_index = start_index
    end

    def new_assertion_set

    end


    def close
      lines = Readline::HISTORY.to_a
      @end_index ||= Readline::HISTORY.size - 3 # in case of no call to 'bn_close'
      if @end_index < 0 || lines[@start_index..@end_index].empty?
        puts "butterfly_net: #{@file_name} closed, no file written to disk"
        false
      else
        adapter = TestUnitAdapter.new

        lines[@start_index..@end_index].each do |line|
          adapter.add_command(line)
        end

        adapter.create_file(@file_name)

        puts "butterfly_net: #{@file_name} closed after Readline::HISTORY ##{@end_index}"
        true
      end
    rescue Exception => msg
      puts "butterfly_net:  Error generating tests: #{msg}"
      false
    end

  end

end
