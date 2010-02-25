module ButterflyNet
  class FileWriter

    attr_accessor :end_index
    attr_reader :start_index

    def initialize(file_name)

      check_for_readline
      # todo: if Rails, WARNING if env is not test

      start_index = Readline::HISTORY.empty? ? 0 : (Readline::HISTORY.size - 1)
      file_name ||= "butterfly_net_#{Time.now.strftime("%Y%m%d%H%M%S")}.rb"
      file_name += ".rb" unless file_name =~ /.rb$/
      @file_name = file_name
      @start_index = start_index
      @adapter = TestUnitAdapter.new
    end

    def new_assertion_set(method_name)
      check_for_readline

      lines = Readline::HISTORY.to_a
      @end_index ||= Readline::HISTORY.size - 3 # in case of no call to 'bn_close'
      if @end_index < 0 || lines[@start_index..@end_index].empty?
        false
      else


        lines[@start_index..@end_index].each do |line|
          @adapter.add_command(line)
        end

        @adapter.close_assertion_set(method_name)
        @start_index = Readline::HISTORY.size - 1
        @end_index = nil

        true
      end
    rescue Exception => e
      puts "butterfly_net:  Error generating tests: #{e}"
      puts e.backtrace
      false
    end


    def close
      check_for_readline
      lines = Readline::HISTORY.to_a
      @end_index ||= Readline::HISTORY.size - 3 # in case of no call to 'bn_close'
      if @end_index < 0 || lines[@start_index..@end_index].empty?
      else
        lines[@start_index..@end_index].each do |line|
          @adapter.add_command(line)
        end

      end

      result = @adapter.create_file(@file_name)
      puts result ? "butterfly_net: #{@file_name} created." : "butterfly_net: #{@file_name} was not created. No tests were generated from this session."
      result

    rescue Exception => e
      puts "butterfly_net:  Error generating tests: #{e}"
      puts e.backtrace
      false
    end


    def check_for_readline
      raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    end

  end
end
