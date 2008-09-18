require 'optparse'

$ClassXCommandableMappingOf = {}

module ClassX
  # add cli interface to your classx based class.
  #
  #   require 'classx'
  #
  #   $ClassXCommandableMappingOf[Symbol] = String
  #
  #   class YourApp 
  #     include ClassX
  #     extend ClassX::Commandable
  #
  #     has :arg1, 
  #       :kind_of => Symbol, 
  #       :desc => 'please specify arg1',
  #       :coerce => { String => proc {|val| val.to_sym } }
  #
  #     has :arg2,
  #       :kind_of => Integer,
  #       :desc => "this is arg2",
  #       :optional => true
  #
  #     def run
  #       # do something!!
  #       p attribute_of
  #     end
  #   end
  #
  #   if $0 == __FILE__
  #     YourApp.from_argv.run
  #   end
  #
  # and run, $ruby example/commandable.rb
  #
  #   example/commandable.rb [options]
  #       -a, --arg1 String                please specify arg1
  #           --arg2 [Integer]             this is arg2
  #       -h, --help                       show this document
  #
  # please see and run example/commandable.rb
  #
  module Commandable
    class MissingCoerceMapping < Exception; end

    def from_argv argv=ARGV.dup
      OptionParser.new do |opt|
        begin
          opt.banner = "#{$0} [options]"
          value_of = {}
          short_option_of = {}
          attribute_of.keys.sort.each do |key|
            val = attribute_of[key]
            next if val.config[:no_cmd_option]
            
            val_format = val.value_class ? "#{val.value_class}" : "VAL"
            if val.optional?
              val_format = "[#{val_format}]"
            end

            short_option = key.split(//).first
            unless short_option_of[short_option]
              short_option_of[short_option] = key
            end

            if val.value_class
              begin
                if short_option_of[short_option] == key
                  opt.on(
                    "-#{short_option}", 
                    "--#{key} #{val_format}", 
                    val.value_class, val.desc
                  ) {|v| value_of[key] = v }
                else
                  opt.on("--#{key} #{val_format}", val.value_class, val.desc) {|v| value_of[key] = v }
                end
              rescue Exception => e
                if $ClassXCommandableMappingOf[val.value_class]
                  if short_option_of[short_option] == key
                    opt.on(
                      "-#{short_option}", 
                      "--#{key} #{$ClassXCommandableMappingOf[val.value_class]}", 
                      $ClassXCommandableMappingOf[val.value_class], val.desc
                    ) {|v| value_of[key] = v }
                  else
                    opt.on(
                      "--#{key} #{$ClassXCommandableMappingOf[val.value_class]}", 
                      $ClassXCommandableMappingOf[val.value_class], val.desc
                    ) {|v| value_of[key] = v }
                  end
                else
                  raise MissingCoerceMapping, "missing coerce rule. please specify $ClassXCommandableMappingOf"
                end
              end
            else
              if short_option_of[short_option] == key
                opt.on("-#{short_option}", "--#{key} #{val_format}", val.desc ) {|v| value_of[key] = v }
              else
                opt.on("--#{key} #{val_format}", val.desc ) {|v| value_of[key] = v }
              end
            end
          end

          opt.on('-h', '--help', 'show this document') {|v| raise OptionParser::ParseError }
          opt.parse!(argv)

          return new(value_of)
        rescue ClassX::InstanceException, OptionParser::ParseError => e
          warn opt
          exit
        end
      end
    end
  end
end
