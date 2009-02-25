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

desc 'run benchmark script'
task :benchmark do
  require 'pathname'

  base_dir = Pathname(File.expand_path(File.join(File.dirname(__FILE__), 'bench')))
  base_dir.children.each do |script|
    next unless script.to_s =~ /\.rb$/
    outfile = "#{script}.result.txt"
    system("echo '--------------' >> #{outfile}")
    system("git show HEAD --pretty=oneline --stat | head -n 1 >> #{outfile}")
    system("echo '--------------' >> #{outfile}")
    system("ruby #{script} >> #{outfile}")
  end
end

desc 'run generate benchmark history'
task :benchmark_all do
  require 'pathname'
  require 'yaml'

  base_dir = Pathname(File.expand_path(File.join(File.dirname(__FILE__), 'bench')))

  base_dir.children.each do |script|
    next unless script.to_s =~ /\.rb$/

    # extract DATA section from script
    yaml = ""
    File.open(script) do |f|
      rev_fg = false
      f.each do |line|
        if  /^__END__$/ =~ line
          rev_fg = true
          next
        end

        next unless rev_fg
        yaml << line
      end
    end

    unless yaml == ""
      outfile = "#{script}.result.txt"

      rm outfile if File.exist? outfile

      revisions = YAML.load(yaml)

      tmp_script = "#{base_dir}/.backup.rb"
      begin
        cp script, tmp_script
        revisions.each do |rev|
          system("git checkout #{rev['sha1']}")
          system("echo '--------------' >> #{outfile}")
          system("git show HEAD --pretty=oneline --stat | head -n 1 >> #{outfile}")
          system("echo '--------------' >> #{outfile}")
          system("ruby #{tmp_script} >> #{outfile}")
        end
      ensure
        rm tmp_script
        system("git checkout master")
      end
    end
  end
end

task :package => [:benchmark_all]

import File.join(File.dirname(__FILE__), 'tasks', 'basic_tasks.rake')
