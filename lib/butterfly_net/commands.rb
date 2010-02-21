#
# Command shortcuts:
#
# bn  - open a new Butterfly Net test case, with optional name
# bnc - close Butterfly Net test case, writing output file
# bns - add preceding line to setup method, instead of current assertion set           # todo
# bnt - add preceding line to teardown method, instead of current assertion set        # todo
#
module ButterflyNet
  module Commands

    def bn_open(file_name=nil)


      @file.close if @file
      check_for_readline
      # todo: if Rails, WARNING if env is not test

      start_index = Readline::HISTORY.empty? ? 0 : (Readline::HISTORY.size - 1)
      file_name ||= "butterfly_net_#{Time.now.strftime("%Y%m%d%H%M%S")}.rb"
      file_name += ".rb" unless file_name =~ /.rb$/
      @file = FileWriter.new(file_name, start_index)
      Kernel.at_exit { puts @file.close if @file; @file = nil }
      true
    rescue
      false
    end

    def bn_close
      check_for_readline
      if @file
        status = @file.close
        @file = nil
        status
      else
        puts "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session"
        false
      end
    end

    def bn_method(method_name=nil)
      check_for_readline
      if @file
        @file.new_assertion_set(method_name)
      else
        puts "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session"
        false
      end
    end


    alias :bn :bn_open
    alias :bnc :bn_close
    alias :m :bn_method

    private

    def check_for_readline
      raise "butterfly_net: Readline::HISTORY required!" unless defined? Readline::HISTORY
    end

  end
end