require 'optparse'

$ClassXCommandableMappingOf = {}

class ClassX
  module Commandable
    class MissingCoerceMapping < Exception; end

    def from_argv argv=ARGV.dup
      OptionParser.new do |opt|
        begin
          opt.banner = "#{$0} [options]"
          value_of = {}
          attribute_of.each do |key, val|
            
            val_format = val.value_class ? val.value_class : "VAL"
            if val.optional?
              val_format = "[ #{val_format} ]"
            end

            if val.value_class
              begin
                opt.on("--#{key} #{val_format}", val.value_class, val.desc) {|v| value_of[key] = v }
              rescue Exception => e
                if $ClassXCommandableMappingOf[val.value_class]
                  opt.on("--#{key} #{val_format}", $ClassXCommandableMappingOf[val.value_class], val.desc) {|v| value_of[key] = v }
                else
                  raise MissingCoerceMapping, "missing coerce rule. please specify $ClassXCommandableMappingOf"
                end
              end
            else
              opt.on("--#{key} #{val_format}") {|v| value_of[key] = v }
            end
          end

          opt.on('-h', '--help', 'show this document') {|v| raise OptionParser::ParseError }
          opt.parse!(argv)
          return new(value_of)
        rescue ClassX::AttrRequiredError, OptionParser::ParseError => e
          warn opt
          exit
        end
      end
    end
  end
end
