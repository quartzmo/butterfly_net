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
      @readline_reader.close if @readline_reader
      @readline_reader = ReadlineReader.new(file_name)
      Kernel.at_exit { puts @readline_reader.close if @readline_reader; @readline_reader = nil }
      true
    rescue Exception => e
      puts e
      puts e.backtrace
      false
    end

    def bn_close
      if @readline_reader
        status = @readline_reader.close
        @readline_reader = nil
        status
      else
        puts "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session"
        false
      end
    end

    def bn_method(method_name=nil)
      if @readline_reader
        @readline_reader.new_assertion_set(method_name)
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