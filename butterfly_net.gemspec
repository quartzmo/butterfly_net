require 'rubygems'
SPEC = Gem::Specification.new do |s|
  s.name = "butterfly_net"
  s.version = "0.0.1"
  s.author = "Chris Smith"
  s.email = "quartzmo@gmail.com"
  s.homepage = "http://github.com/quartzmo/butterfly_net"
  s.summary = "Record your IRB sessions as Test::Unit tests. (RSpec and others hopefully soon to come.)"
  s.description = <<EOF
INSTALL

    Butterfly Net is available for download as a gem from github.com.

    sudo gem install butterfly_net

    To automatically load add Butterfly Net on every IRB session, add the following to your ~/.irbrc:

    require 'rubygems'
    require 'butterfly_net'

USAGE

    Command shortcuts available in IRC:

    bn  - open a new Butterfly Net test case, with optional file name string ('.rb' will be appended if not present)
    bnc - close Butterfly Net test case, writing output file

EOF
  s.files = Dir.glob("**/*")
  s.require_path = "lib"
  s.test_file = "test/butterfly_net_tests.rb"
  s.has_rdoc = false
end
