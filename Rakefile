require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/contrib/sshpublisher'
require 'fileutils'
include FileUtils

load File.join(File.dirname(__FILE__), 'tasks', 'basic_config.rake')

NAME              = "classx"
DESCRIPTION       = <<-"END_DESCRIPTION"
Meta Framework extending and flexible attribute like Moose ( perl )
END_DESCRIPTION
BIN_FILES         = %w(  )
VERS              = "0.0.7"

EXTRA_RDOC_FILES = []
HECKLE_ROOT_MODULES = ["Classx"]

SPEC = Gem::Specification.new do |s|
	s.name              = NAME
	s.version           = VERS
	s.platform          = Gem::Platform::RUBY
	s.has_rdoc          = true
	s.extra_rdoc_files  = DEFAULT_EXTRA_RDOC_FILES + EXTRA_RDOC_FILES
	s.rdoc_options     += RDOC_OPTS + ['--title', "#{NAME} documentation", ]
	s.summary           = DESCRIPTION
	s.description       = DESCRIPTION
	s.author            = AUTHOR
	s.email             = EMAIL
	s.homepage          = HOMEPATH
	s.executables       = BIN_FILES
	s.rubyforge_project = RUBYFORGE_PROJECT
	s.bindir            = "bin"
	s.require_path      = "lib"
	s.autorequire       = ""
	s.test_files        = Dir["spec/*_spec.rb"]

  if Gem::RubyGemsVersion >= "1.2"
	  s.add_development_dependency('rspec', '>=1.1.4')
  end
	#s.required_ruby_version = '>= 1.8.2'

	s.files = PKG_FILES + EXTRA_RDOC_FILES
	s.extensions = EXTENSIONS
end

import File.join(File.dirname(__FILE__), 'tasks', 'basic_tasks.rake')
