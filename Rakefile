#! /usr/bin/env ruby

require_relative "config/environment"

DB = Sequel.sqlite

require 'gemfighter'

DB.create_table :entities do
  primary_key :id
end

DB.create_table :size_components do
  primary_key :id
  foreign_key :entity_id, :entities, 
    :null       => false,
    :on_delete  => :cascade, 
    :index      => true
end

task :test do
  puts "Loaded environment!"
end

task :console do
  items = DB[:items]
  items.insert(:name => 'foo')
  items.insert(:name => 'bar')
  items.insert(:name => 'baz')

  binding.pry
end

task :play do
  Gemfighter.new.start!
end

task :default => :play
