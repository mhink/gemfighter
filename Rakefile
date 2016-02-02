#! /usr/bin/env ruby

require_relative "config/environment"
require 'gemfighter'

task :test do
  puts "Loaded environment!"
end

task :console do
  binding.pry
end

task :play do
  Gemfighter.new.start!
end

task :default => :play
