#! /usr/bin/env ruby

require_relative "config/environment"
require 'gemfighter'
require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

task :test do
  puts "Loaded environment!"
end

task :console do
  game = Gemfighter.new
  binding.pry
end

task :play do
  Gemfighter.new.start!
end

task :glfw do
  load 'glfw_test.rb'
end

task :default => :play
