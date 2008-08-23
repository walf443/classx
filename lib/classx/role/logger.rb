require 'logger'

class ClassX
  module Role
    # SYNOPSIS
    #
    #   require 'classx/role/logger'
    #   class YourApp < ClassX
    #     extends ClassX::Commandable
    #     include ClassX::Role::Logger
    #   
    #     def run
    #       logger.debug("debug!!")
    #       # do something
    #     end
    #   end
    #
    # and run following:
    #
    #   $ your_app.rb --logfile log/debug.log --log_level debug
    #
    # SEE ALSO: +ClassX::Commandable+
    #
    module Logger
      extend ClassX::Attributes

      module ToLogLevel
        def to_log_level str=self.get
          ::Logger::Severity.const_get(str.upcase)
        end

        alias to_i to_log_level
      end

      has :logger, 
        :lazy          => true, 
        :optional      => true,
        :no_cmd_option => true,
        :default       => proc {|mine|
          logger = ::Logger.new(mine.logfile)
          logger.level = mine.attribute_of['log_level'].to_i
          logger.progname = $0

          logger
        }

      has :log_level, 
        :kind_of    => String,
        :desc       => 'log_level (debug|info|warn|error|fatal) (default info)',
        :optional   => true,
        :default    => 'info',
        :include    => ToLogLevel,
        :validate   => proc {|val|
          begin
            ::Logger::Severity.const_get(val.upcase)
          rescue NameError => e
            return false
          end
          true
        }

      has :logfile,
        :kind_of    => String,
        :desc       => 'output logfile. (default STDERR)',
        :optional   => true,
        :default    => $stderr # hmm, is name bad?

    end
  end
end
