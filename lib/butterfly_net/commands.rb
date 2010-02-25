#
# Command shortcuts:
#
# bn  - open a new Butterfly Net test case, with optional name
# bnc - close Butterfly Net test case, writing output file
# m   - close current test method, and open a new one
# bns - add preceding line to setup method, instead of current assertion set           # todo
# bnt - add preceding line to teardown method, instead of current assertion set        # todo
#
module ButterflyNet
  module Commands

    def bn_open(file_name=nil)
      @file_writer.close if @file_writer
      @file_writer = ReadlineReader.new(file_name)
      Kernel.at_exit { puts @file_writer.close if @file_writer; @file_writer = nil }
      true
    rescue Exception => e
      puts e
      puts e.backtrace
      false
    end

    def bn_close
      if @file_writer
        status = @file_writer.close
        @file_writer = nil
        status
      else
        puts "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session"
        false
      end
    end

    def bn_method(method_name=nil)
      if @file_writer
        @file_writer.new_assertion_set(method_name)
      else
        puts "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session"
        false
      end
    end

    alias :bn :bn_open
    alias :bnc :bn_close
    alias :m :bn_method

  end
end