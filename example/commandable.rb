$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib' )))
require 'classx'
require 'classx/commandable'
require 'classx/role/logger'
require 'pp'

$ClassXCommandableMappingOf[Symbol] = String

class YourApp 
  include ClassX
  extend ClassX::Commandable
  include ClassX::Role::Logger

  has :arg1, 
    :kind_of => Symbol, 
    :desc => 'please specify arg1',
    :coerce => { String => proc {|val| val.to_sym } }

  has :arg2,
    :kind_of => Integer,
    :desc => "this is arg2",
    :optional => true

  def run
    # do something!!
    logger.info('starting your_app')
    logger.debug(attribute_of.pretty_inspect)
    logger.info('end your app')
  end
end

if $0 == __FILE__
  YourApp.from_argv.run
end
