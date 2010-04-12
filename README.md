Butterfly Net
=============



[Home page and source download](http://github.com/quartzmo/butterfly_net)

[RubyGems page](http://rubygems.org/gems/butterfly_net)


## Summary

IRB and Rails console history captured as Test::Unit tests. (RSpec and others hopefully soon to come.)

## Description

Butterfly Net is intended to help you capture, as executable tests, surprising or unexpected behavior that you come across while
interacting with your project code in IRB.

** Warning **

Butterfly Net is not a tool for [test-first](http://www.extremeprogramming.org/rules/testfirst.html) development, and is
not intended as a primary tool for [Test-Driven Development](http://en.wikipedia.org/wiki/Test-driven_development) (TDD).
Please use it in addition to these valuable methods.

## Install

Butterfly Net is available as a gem from [rubygems.org](http://rubygems.org/gems/butterfly_net), or as source from
[GitHub](http://github.com/quartzmo/butterfly_net).

To install the gem:

    sudo gem install butterfly_net

To automatically require Butterfly Net on every IRB session, add the following to your ~/.irbrc:

    require 'rubygems'
    require 'butterfly_net'


## Usage

### Command methods

The following commands can be used in any IRB-based console. The shortcuts should be preferred, the longer aliases exist in case of naming conflicts.

* `bn(file_name=nil)`, `bn_open(file_name=nil)`       Open a new test case, closing the current test case if one exists. Args: file_name:string (optional; '.rb' will appended if needed)
* `bnc`, `bn_close`     Close the active test case, and write the output to a file.
* `m(method_name=nil)`, `bn_method(method_name=nil)`      Close the current test method (or block), naming it with the arg method_name:string (optional)

### Example Usage in IRB

    $ irb
    irb(main):001:0> require 'rubygems'
    => true
    irb(main):002:0> require 'butterfly_net'
    => true
    irb(main):003:0> bn 'irb_tests'
    => true
    irb(main):004:0> a = 1
    => 1
    irb(main):005:0> a += 2
    => 3
    irb(main):006:0> m 'plusequals'
    => true
    irb(main):007:0> require 'bigdecimal'
    => true
    irb(main):008:0> infinity = BigDecimal('Infinity')
    => #<BigDecimal:114ed34,'Infinity',4(4)>
    irb(main):009:0> BigDecimal.new("1.0") / BigDecimal.new("0.0") == infinity
    => true
    irb(main):010:0> m 'bigdecimal_infinity'
    => true
    irb(main):011:0> exit
    butterfly_net: irb_tests.rb closed
    true
    $ cat irb_tests.rb
    require "test/unit"

    # IRB test capture courtesy of butterfly_net (butterflynet.org)
    class MyTest < Test::Unit::TestCase

      def test_plusequals
        a = 1
        assert_equal(3, a += 2)
      end

      def test_bigdecimal_infinity
        require 'bigdecimal'
        infinity = BigDecimal('Infinity')
        assert(BigDecimal.new("1.0") / BigDecimal.new("0.0") == infinity)
      end

    end
    $ ruby irb_tests.rb
    Loaded suite irb_tests
    Started
    ..
    Finished in 0.001603 seconds.

    2 tests, 2 assertions, 0 failures, 0 errors


### Ruby on Rails console

For repeatable tests, be sure to load the Rails test environment with `./script/console test`. Invoke the `bn` command
with the relative path to the appropriate test sub-directory, and file name. (Hint: In a Rails project, you can run an 
individual test by adding the test directory to the path with the option -I when you invoke Ruby.)

For example:

    $ ./script/console test
    Loading test environment (Rails 2.3.4)
    >> bn "test/unit/person_console_test"
    . . .
    >> Person.count
    => 2
    >> exit
    . . .
    $ ruby -Itest test/unit/person_console_test.rb
    . . .
    1 tests, 1 assertions, 0 failures, 0 errors


## To-do List

1. Improve overall stability (probably an on-going, long-term todo, but we can always hope).
2. Support multi-line blocks.
3. Write tests to file immediately rather than upon exit.
4. Support expected errors with assert_raises.
5. Provide an 'oops' shortcut method to capture unexpected errors in failing tests.
6. Compare complex objects by value.


## Known Issues

This section covers issues which may not be resolved quickly. Feel free to lend a hand!

### The return value of Object#inspect is often not valid Ruby

Currently, the expectation that Butterfly Net places into an assertion is the output of Object#inspect. Simple types and value-oriented
types such as Hash and Array usually do return valid code, which works great. Unfortunately, most other types respond with the familiar
`#<...>` notation, which can't be interpreted.

For example:

    assert_equal(#<BigDecimal:11511d8,'Infinity',4(24)>, BigDecimal.new("1.0") / BigDecimal.new("0.0"))  # doesn't work

The best workaround is to use IRB in a way that gets you to simple types, the same way you write unit tests that
compare values by calling `to_s`, `to_i`, `to_f`, etc on more complex objects.
Another solution, more appropriate for cases like the BigDecimal infinity example above, is to assign the expected
result to a variable.

    infinity = BigDecimal('Infinity')
    assert(BigDecimal.new("1.0") / BigDecimal.new("0.0") == infinity)    # works great, IF you know what to expect

Of course, you have to know what to expect in order to do this, which may take a few tries. Sorry.
I'll be searching for a better solution to this one.


### Assigning a variable, even within a string, results in no assertion for that line 

To keep tests readable, Butterfly Net writes simple assignment expressions such as "a = 1" without enclosing assertions.
However, the regular expression it uses to accomplish this can cause Butterfly Net to miss some tests.

For example:

    irb(main):002:0> a = 1; a + 1
    => 2
    irb(main):003:0> "a=1".split('=')
    => ["a", "1"]

results in

    def test_1
      a = 1; a + 1           # should have been a = 1; assert_equal(2, a + 1)
      "a=1".split('=')       # should have been assert_equal(["a", "1"],"a=1".split('='))
    end

Maybe someone can suggest how Butterfly Net can become just enough of an actual Ruby interpreter to get past this issue?
In the meantime, just put assignments (and anything that looks like an assignment) on separate lines 
from the expressions you want to be tested.


## Credits

[Chris Smith](http://github.com/quartzmo) (quartzmo -at- gmail.com)

[Caleb Clausen](http://github.com/quartzmo)

## Story

Coming to Ruby from Java, I felt "The Console" was like a magical English butler, always there discreetly
at my side to instantly and precisely answer all my questions. How incredible!

In Java, JUnit had been my preferred tool for exploring code, both my own project code and
third-party libraries and frameworks. As anyone who has worked on a legacy (i.e., test-deprived) codebase or experienced
java.util.Calendar knows, the tighter the feedback loop, the sooner you get your answers. Experimenting with code behavior through an
application UI is only for the foolish, or those racking up billable hours on a big waterfall project.
JUnit tests were usually the fastest way I could experience what code did in real life, and with IntelliJ IDEA generating the
boilerplate at a keystroke, exploratory testing was quick and very acceptable. When I was done learning and
experimenting, I deleted most of the tests, in accordance with the idea that less is better, and you shouldn't
run automated regression tests for stable, third-party code.

Switching to Ruby, I found IRB to be a much better tool, but as with all great conveniences, it had a downside.
Although I generally program in a test-first style, I also explore existing code after it is written,
kicking the tires and banging on the doors. With JUnit, any interesting behavior I discovered during this process was captured in a
test, and was duly added to the suite. With IRB? Gone, flown off into the deep blue yonder. The idea for Butterfly Net
occurred to me pretty quickly. That's the story, so far. I'm not sure how others will use Butterfly Net, but I don't
want to limit the possibilities. Should it become more generalized and flexible, something of a view framework like
[Hirb](http://github.com/cldwalker/hirb)? Or did I re-invent something that already existed?

UPDATE (4/12/2010)

It was done before.

After a short demo of Butterfly Net at [MountainWest RubyConf](http://mtnwestrubyconf.org), I was approached by
[Caleb Clausen](http://github.com/quartzmo), who offered to help with the project. Years ago, Caleb wrote a similar library for
his own use, IRBTrack, which was much more sophisticated than the current implementation of Butterfly Net. He had never
released IRBTrack and believed it to have been lost forever, but recently he found the code and shared it with me. The
next version of Butterfly Net will be a merge of the two projects, and I am happy to have Caleb join me as a contributor to Butterfly Net.

Please send comments and suggestions to quartzmo -at- gmail.com


## License

The MIT License

Copyright (c) 2010 Chris Smith

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
