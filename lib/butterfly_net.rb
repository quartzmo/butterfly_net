
bn_libdir = File.join( File.dirname(__FILE__), 'butterfly_net')

require File.join(File.dirname(__FILE__), 'rbeautify')
require File.join(bn_libdir , 'file_writer')
require File.join(bn_libdir , 'definitions')
require File.join(bn_libdir , 'test_unit_method')
require File.join(bn_libdir , 'test_unit_adapter')
require File.join(bn_libdir , 'rails_test_unit_adapter')
require File.join(bn_libdir , 'test_case')
require File.join(bn_libdir , 'commands')

include ButterflyNet::Commands