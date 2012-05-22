$:.push File.expand_path("../lib", __FILE__)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "./spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = "./spec/**/*_spec.rb"
  spec.rcov = true
end
