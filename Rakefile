require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

ENV["MIMIC_TEST_PROXY"] = nil

desc "Run all Cucumber features"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
end

task :default => :spec
task :all => [:spec, :features]

require "rubygems/package_task"
require "rdoc/task"

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "mimic"
  s.version           = "0.4.3"
  s.summary           = "A Ruby gem for faking external web services for testing"
  s.authors           = "Luke Redpath"
  s.email             = "luke@lukeredpath.co.uk"
  s.homepage          = "http://lukeredpath.co.uk"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README.md)
  s.rdoc_options      = %w(--main README.md)

  # Add any extra files to include in the gem
  s.files             = %w(LICENSE CHANGES Rakefile README.md) + Dir.glob("{spec,lib/**/*}")
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("rack")
  s.add_dependency("sinatra")
  s.add_dependency("thin")
  s.add_dependency("json")
  s.add_dependency("plist", "~> 3.1.0")

  # If your tests use any gems, include them here
  s.add_development_dependency("rspec", "~> 2.4.0")
  s.add_development_dependency("cucumber")
  s.add_development_dependency("mocha")
  s.add_development_dependency("rest-client")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

task :package => :gemspec

# Generate documentation
RDoc::Task.new do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

task 'Release if all specs pass'
task :release => [:clean, :bundle, :spec, :features, :package] do
  system("gem push pkg/#{spec.name}-#{spec.version}.gem")
end

desc 'Install all gem dependencies'
task :bundle => :gemspec do
  system("bundle")
end
