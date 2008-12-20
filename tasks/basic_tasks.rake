
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
CLEAN.include ['**/.*.sw?', '*.gem', '.config']

Rake::GemPackageTask.new(SPEC) do |p|
	p.need_tar = true
	p.gem_spec = SPEC
end

task :default => [:spec]
task :test    => [:spec]
task :package => [:clean]

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
  t.warning = true
  t.rcov = true
  t.rcov_dir = 'doc/output/coverage'
  t.rcov_opts = ['--exclude', 'spec,\.autotest,/Library/']
end

desc "Heckle each module and class in turn"
task :heckle => :spec do
  root_modules = HECKLE_ROOT_MODULES
  spec_files = FileList['spec/**/*_spec.rb']
  
  current_module, current_method = nil, nil
  heckle_caught_modules = Hash.new { |hash, key| hash[key] = [] }
  unhandled_mutations = 0
  
  root_modules.each do |root_module|
    IO.popen("heckle #{root_module} -t #{spec_files}") do |pipe|
      while line = pipe.gets
        line = line.chomp
        
        if line =~ /^\*\*\*  ((?:\w+(?:::)?)+)#(\w+)/
          current_module, current_method = $1, $2
        elsif line == "The following mutations didn't cause test failures:"
          heckle_caught_modules[current_module] << current_method
        elsif line == "+++ mutation"
          unhandled_mutations += 1 
        end
              
        puts line
      end
    end
  end
  
  if unhandled_mutations > 0
    error_message_lines = ["*************\n"]
    
    error_message_lines << 
      "Heckle found #{unhandled_mutations} " + 
      "mutation#{"s" unless unhandled_mutations == 1} " +
      "that didn't cause spec violations\n"

    heckle_caught_modules.each do |mod, methods|
      error_message_lines <<
        "#{mod} contains the following poorly-specified methods:"
      methods.each do |m| 
        error_message_lines << " - #{m}"
      end
      error_message_lines << ""
    end
    
    error_message_lines <<
      "Get your act together and come back " +
      "when your specs are doing their job!"
    
    puts "*************"
    raise error_message_lines.join("\n")
  else
    puts "Well done! Your code withstood a heckling."
  end
end

require 'spec/rake/verify_rcov'
RCov::VerifyTask.new(:rcov => :spec) do |t|
  t.index_html = "doc/output/coverage/index.html"
  t.threshold = 100
end

task :install do
	name = "#{NAME}-#{VERS}.gem"
	sh %{rake package}
	sh %{sudo gem install pkg/#{name}}
end

task :uninstall => [:clean] do
	sh %{sudo gem uninstall #{NAME}}
end

begin
  allison_path = `allison --path`.chomp
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'html'
    rdoc.options += RDOC_OPTS
    rdoc.template = allison_path
    if ENV['DOC_FILES']
      rdoc.rdoc_files.include(ENV['DOC_FILES'].split(/,\s*/))
    else
      rdoc.rdoc_files.include('README', 'ChangeLog')
      rdoc.rdoc_files.include('lib/**/*.rb')
      rdoc.rdoc_files.include('ext/**/*.c')
    end
  end
rescue Exception => e
  warn e
  warn "skipping rdoc task"
ensure
end

desc "Publish to RubyForge"
task :rubyforge => [:rdoc, :package] do
	require 'rubyforge'
	Rake::RubyForgePublisher.new(RUBYFORGE_PROJECT, 'yoshimi').upload
end

desc 'Package and upload the release to rubyforge.'
task :release => [:clean, :package] do |t|
	require 'rubyforge'
	v = ENV["VERSION"] or abort "Must supply VERSION=x.y.z"
	abort "Versions don't match #{v} vs #{VERS}" unless v == VERS
	pkg = "pkg/#{NAME}-#{VERS}"

	rf = RubyForge.new
	puts "Logging in"
	rf.login

	c = rf.userconfig
#	c["release_notes"] = description if description
#	c["release_changes"] = changes if changes
	c["preformatted"] = true

	files = [
		"#{pkg}.tgz",
		"#{pkg}.gem"
	].compact

	puts "Releasing #{NAME} v. #{VERS}"
	rf.add_release RUBYFORGE_PROJECT_ID, RUBYFORGE_PACKAGE_ID, VERS, *files
end
