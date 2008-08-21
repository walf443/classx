class ClassX
  module Util
    def has_writer name, options={}
      options[:writable] ||= true 
      has name, options
    end

    def has_writer_with_default name, default, options={}
      options[:default]  ||= default
      options[:optional] ||= true 
      has_writer name, options
    end

    def has_reader name, options={}
      options[:writable] ||= false
      has name, options
    end

    def has_reader_with_default name, default, options={}
      options[:default] ||= default
      has_reader name, options
    end
  end
end
