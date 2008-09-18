require 'logger'

module ClassX
  module Role
    # SYNOPSIS
    #
    #   require 'classx/role/logger'
    #   class YourApp 
    #     include ClassX
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
    module Logger #:doc:
      extend ClassX::Attributes

      # added log_level's attribute class to utility method
      #
      #   your_class.attribute_of['log_level'].to_log_level #=> 0
      #   your_class.attribute_of['log_level'].to_i # alias for to_log_level
      #
      module ToLogLevel #:nodoc:
        def to_log_level str=self.get
          ::Logger::Severity.const_get(str.upcase)
        end

        alias to_i to_log_level
      end

      def logger; end # dummy method for rdoc

      # you can use logger.debug, logger.info or logger.warn.
      # default output is $stderr.
      # see also Logger
      has :logger, {
        :optional      => true,
        :no_cmd_option => true,
        :lazy          => true,
        :default       => proc {|mine|
          logger = ::Logger.new(mine.logfile)
          logger.level = mine.attribute_of['log_level'].to_i
          logger.progname = $0

          logger
        }
      }

      # log_level (debug|info|warn|error|fatal) ( default info )
      has :log_level, {
        :kind_of    => String,
        :desc       => 'log_level (debug|info|warn|error|fatal) (default info)',
        :optional   => true,
        :default    => 'info',
        :include    => ToLogLevel,
        :validate   => proc {|val|
          val && ::Logger::Severity.const_defined?(val.to_s.upcase)
        },
      }

      # output logfile ( default STDERR ).
      has :logfile, {
        :kind_of    => String,
        :desc       => 'output logfile. (default STDERR)',
        :optional   => true,
        :default    => $stderr, # hmm, is name bad?
      }

    end
  end
end
