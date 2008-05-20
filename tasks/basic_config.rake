AUTHOR            = "Keiji, Yoshimi"
EMAIL             = "walf443 at gmail.com"
RUBYFORGE_PROJECT = "akasakarb"
RUBYFORGE_PROJECT_ID = 4314
HOMEPATH          = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
RDOC_OPTS = [
	"--charset", "utf-8",
	"--opname", "index.html",
	"--line-numbers",
	"--main", "README",
	"--inline-source",
  '--exclude', '^(example|extras)/'
]
DEFAULT_EXTRA_RDOC_FILES = ['README', 'ChangeLog']
PKG_FILES = [ 'Rakefile' ] + 
  DEFAULT_EXTRA_RDOC_FILES +
  Dir.glob('{bin,lib,test,spec,doc,tasks,script,generator,templates,extras,website}/**/*') + 
  Dir.glob('ext/**/*.{h,c,rb}') +
  Dir.glob('examples/**/*.rb') +
  Dir.glob('tools/*.rb')

EXTENSIONS = FileList['ext/**/extconf.rb'].to_a
