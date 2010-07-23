require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rchart"
    gem.summary = %Q{Ruby port of the slick pChart charting library }
    gem.description = %Q{Ruby port of the slick pChart charting library}
    gem.email = "amardaxini@gmail.com"
    gem.homepage = "http://github.com/amardaxini/rchart"
    gem.authors = ["amardaxini"]
    gem.rubyforge_project = "rchart"
#    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "ruby-gd",">=0.8.0"
    gem.files = [Dir['fonts/*'],Dir['examples/*'],".document", ".gitignore","LICENSE","README.rdoc","Rakefile","VERSION",  "lib/rchart.rb","lib/rdata.rb","lib/version.rb","test/helper.rb","test/test_rchart.rb"]
    gem.requirements << "libgd-ruby, libpng-dev, libgd-dev package are required"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rchart #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
