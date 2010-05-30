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
      # @readline_reader.close if @readline_reader
      if file_name
        @file_name = file_name.to_s + ".rb" unless file_name.to_s =~ /.rb$/
      else
        @file_name = "butterfly_net_#{Time.now.strftime("%Y%m%d%H%M%S")}.rb"  # todo: something like heroku's generated names
      end
      @test_case = TestCase.new
      Kernel.at_exit { puts bn_close if @test_case; @test_case = nil }
      @test_case
    rescue Exception => e
      puts e
      puts e.backtrace
      nil
    end

    def bn_close
      if @test_case
        begin
          result = @test_case.create_file(@file_name)
          puts result ? "butterfly_net: #{@file_name} created." : "butterfly_net: #{@file_name} was not created. No tests were generated from this session."
          @test_case = nil
          result
        rescue Exception => e
          puts "butterfly_net:  Error generating tests: #{e}"
          puts e.backtrace
          false
        end
      else
        puts "butterfly_net: First invoke 'bn' or 'bn_open' to begin a session"
        false
      end
    end

    def bn_method(method_name=nil)
      if @test_case
        begin
          @test_case.close_assertion_set(method_name)
        rescue Exception => e
          puts "butterfly_net:  Error generating tests: #{e}"
          puts e.backtrace
          false
        end
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