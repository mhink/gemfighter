require 'rubygems'
require 'bundler/setup'
Bundler.require :default
require 'pry'

require 'active_support'
require 'active_support/core_ext'

include Geometry

BASE_DIR = Pathname.new(File.dirname(__FILE__)).join("..")

LIB_DIR  = BASE_DIR.join("lib")
GAME_DIR = BASE_DIR.join("game")
RES_DIR  = BASE_DIR.join("res")

$LOAD_PATH.unshift(LIB_DIR) unless $LOAD_PATH.include?(LIB_DIR)
$LOAD_PATH.unshift(GAME_DIR) unless $LOAD_PATH.include?(GAME_DIR)

require 'gemfighter'
