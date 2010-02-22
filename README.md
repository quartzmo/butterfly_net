Butterfly Net
=============

[Home page and source download](http://butterflynet.org)
[RubyGems page](http://rubygems.org/gems/butterfly_net)

Author: Chris Smith (quartzmo -at- gmail.com)


## DESCRIPTION

IRB and Rails console history captured as Test::Unit tests. (RSpec and others hopefully soon to come.)


## INSTALL

Butterfly Net is available as a gem from [rubygems.org](http://rubygems.org/gems/butterfly_net), or as source from
[butterflynet.org](http://butterflynet.org).

To install the gem:

    sudo gem install butterfly_net

To automatically require Butterfly Net on every IRB session, add the following to your ~/.irbrc:

    require 'rubygems'
    require 'butterfly_net'


## USAGE

### Command methods

The following commands can be used in any IRB-based console.

* bn, bn_open- Open a new test case, closing the current test case if one exists. Args: file_name:string (optional; '.rb' will appended if needed)
* bnc, bn_close  - Close the active test case, and write the output to a file.
* m, bn_method   - Close the current test method (or block), naming it with the arg method_name:string (optional)

### Example Usage in IRB

    $ irb
    irb(main):001:0> bn 'irb_tests'
    => true
    irb(main):002:0> a = 1
    => 1
    irb(main):003:0> a += 2
    => 3
    irb(main):004:0> m 'plusequals'
    => true
    irb(main):005:0> require 'bigdecimal'
    => true
    irb(main):006:0> infinity = BigDecimal('Infinity')
    => #<BigDecimal:114ed34,'Infinity',4(4)>
    irb(main):007:0> BigDecimal.new("1.0") / BigDecimal.new("0.0") == infinity
    => true
    irb(main):008:0> m 'bigdecimal_infinity'
    => true
    irb(main):009:0> exit
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

For repeatable tests, be sure to load the Rails test environment with "./script/console test". Invoke the `bn` command 
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


## KNOWN ISSUES

This section covers issues which may not be resolved quickly. Feel free to lend a hand!

### Object inspect output

Butterfly Net relies on an expectation value responding with valid Ruby code to the inspect method, which is the case for core
classes such as Hash and Array. However, it's not the case with most classes, many of which respond with the familiar
`#<...>` notation, which isn't interpreted.

For example:

    assert_equal(#<BigDecimal:11511d8,'Infinity',4(24)>, BigDecimal.new("1.0") / BigDecimal.new("0.0"))  # doesn't work

The workaround is to assign expected values to a variable. Of course, you have to know what to expect in order to do this, 
which may take a few tries. Sorry.


### Inline variable assignment

Butterfly Net tries to detect simple assignments, such as "a = 1", in order to write them out clearly,
without enclosing assertions. In some cases this causes it to miss statements that should be tested.

For example:

    irb(main):002:0> a = 1; a + 1
    => 2
    irb(main):003:0> "a=1".split('=')
    => ["a", "1"]

results in

    def test_1
      a = 1; a + 1  # should have been a = 1; assert_equal(2, a + 1)
      "a=1".split('=')  # should have been assert_equal(["a", "1"],"a=1".split('='))
    end

In order to avoid this issue, just put assignments (and anything that looks like an assignment) on separate lines.


## LICENSE

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
