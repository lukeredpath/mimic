require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'spec/rake/spectask'

desc "Run all Cucumber features"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

task :default => :specs