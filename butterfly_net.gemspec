require 'rubygems'
SPEC = Gem::Specification.new do |s|
  s.name = "butterfly_net"
  s.version = "0.0.5"
  s.author = "Chris Smith"
  s.email = "quartzmo@gmail.com"
  s.homepage = "http://www.butterflynet.org"
  description_short = "IRB and Rails console history captured as Test::Unit tests."
  s.summary = description_short
  s.description = description_short + " (RSpec and others hopefully soon to come.)"
  s.files = ["README.md"] + Dir['lib/**/*'] + Dir['test/**/*']
  s.require_path = "lib"
  s.test_file = "test/butterfly_net_tests.rb"
  s.has_rdoc = false
end
