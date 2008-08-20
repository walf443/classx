$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib' )))
require 'classx'
require 'classx/commandable'

$ClassXCommandableMappingOf[Symbol] = String

class SomeCommand < ClassX
  extend Commandable

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
    p attribute_of
  end
end

if $0 == __FILE__
  SomeCommand.from_argv.run
end
