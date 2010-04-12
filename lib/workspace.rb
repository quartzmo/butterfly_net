#require '../../irbtrack/common'
require 'irb/workspace'
require 'butterfly_net/test_unit_method'
require 'butterfly_net/definitions'

module IRB
  class WorkSpace
    #def filter_backtrace(x) false end
    alias evaluate__orig evaluate 
    def evaluate(ctx,stmts, file=__FILE__,line=__LINE__)

      @test_unit_method ||= ButterflyNet::TestUnitMethod.new

      return evaluate__orig(ctx,stmts,file,line) if 
        /^__? = /===stmts || /^([\s\t\v\f\n\r])*$/===stmts
        
      
#      if /^(=begin |([\s\t\v\f\n\r])*#[^\r\n]*[\r\n]+)$/===stmts
#        @test_unit_method.write_assertion stmts,"",""
#        return
#      end
      
      #'interpret' the oops pseudocommand
      /^[\s\t\v\f]*oo+ps[\s\t\v\f\r\n]*$/===stmts and return IRBTrack::Log.oops
      
      stmts+="\n" unless stmts[-1]==?\n

      #it's a one-line string if there's a just 1 newline in it at the end; remove that
      stmts.count( "\n")==1 and stmts_is_1_line= stmts.chomp!

      result=nil
      begin
        lvarstr=nil#IRBTrack::Log.lvardeclstr(stmts,@binding,file,line)
        
      #  save_copy_of_stdout_while(output=[]) do
          result=evaluate__orig ctx,stmts,file,line
       # end
      rescue Exception => ee
#        stmts=["eval 'if false",stmts,"end'"].join(stmts_is_1_line ? ';' : "\n") unless lvarstr
        @test_unit_method.write_assertion "%s(%s){%s}",lvarstr.to_s+"assert_raise", lvarstr.to_s+"assert_nothing_raised",  stmts,ee.class
        raise
      end

      # "$stdout should be restored by now whether or not evaluate__orig (or yaml) raised an exception"
=begin
      #if there was (stdio) output, we must save a copy of it 
      #(in the test as well) with this magic function
      output=output.first
      if output and output.size>0
        stmts='(save_copy_of_stdout_while(@@IRBTrack__output=[]){'+stmts+'}, '
      else
        stmts="((#{stmts}), "
        output=nil
      end
=end
      if case result
      when Float;  not result.infinite?
      when Module; result.name!=""
      when Symbol; /^($|@@?)?[a-zA-Z_0-9]+[?!=]?/===result.to_s or #variable
                   /^(~|%|\^|&|\|\*\*?|-|\+|===?|\[\]=?|\||\/|[<>]=?|<<|>>|=~|<=>|\+@|-@|`)$/===result.to_s or #operator
                   /^$(-[a-zA-Z_0-9]|[!@&+'`=0-9~\/\\,.;<>*"$?:])$/===result.to_s #special globals
      when String, nil, true, false, Integer, Regexp; true
      when Method, UnboundMethod; stmts[/, $/]=".inspect, "; result=result.inspect
      end then 
       @test_unit_method.write_assertion "%s(%s,%s)","assert_equal", "assert_not_equal", stmts,result.inspect
       puts "Result: #{@test_unit_method.text} "
      else
        begin
          yaml=IRBTrack::Log.kwote( result.to_yaml, false)
        rescue StandardError,ScriptError,Abort
          puts "couldn't yamlize #{result.inspect}; test is weak"
          @test_unit_method.write_assertion "assert_instance_of ", "assert_not_instance_of ", result.class.to_s+", "+ stmts[1..-3] +"\n"
        else
          stmts<<if yaml.index "\n"
                   ["<<-'###yaml'", yaml, "###yaml\n"].join"\n" 
                 else 
                   IRBTrack::Log.kwote yaml
                 end <<")\n"
          @test_unit_method.write_assertion "assert_equal_yaml", "assert_not_equal_yaml", stmts
        end 
      end
      
      #"need to generate code in unit test that verifies that same output is received"
#      if output
#        String===output or raise "hell"
#        IRBTrack::Log.aheadwrap   "assert_equal  #{output.inspect},@@IRBTrack__output\n",
#                                  "assert_not_equal  #{output.inspect},@@IRBTrack__output\n"
#      end

      return result
    end
  end
end