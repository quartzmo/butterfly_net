Butterfly Net
=============

Project homepage: http://www.butterflynet.org

Author: Chris Smith

Author email: quartzmo -at- gmail.com


## DESCRIPTION

IRB and Rails console history captured as Test::Unit tests. (RSpec and others hopefully soon to come.)


## INSTALL

    gem sources -a http://gemcutter.org
    sudo gem install butterfly_net

To automatically require Butterfly Net on every IRB session, add the following to your ~/.irbrc:

    require 'rubygems'
    require 'butterfly_net'


## USAGE

### Command methods

* bn, bn_open- Open a new test case, closing the current test case if one exists. Args: file_name:string (optional; '.rb' will appended if needed)
* bnc, bn_close  - Close the active test case, and write the output to a file.
* m, bn_method   - Close the current test method (or block), naming it with the arg method_name:string (optional)

### Ruby on Rails console

For repeatable tests, be sure to load the Rails test environment with "./script/console test".
In a Rails project, you can run all tests with the standard rake command 'rake test',
or an individual test by adding the test directory to the path with the option -I when you invoke Ruby.

    chris$ ./script/console test
    Loading test environment (Rails 2.3.4)
    >> bn "test/unit/person_console_test"
    . . .
    >> Person.count
    => 2
    >> exit
    . . .
    chris$ ruby -Itest test/unit/person_console_test.rb
    . . .
    1 tests, 1 assertions, 0 failures, 0 errors


## KNOWN ISSUES

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
