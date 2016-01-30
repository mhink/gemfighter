require 'entity'
require 'component'
require 'window'
require 'registry'

class Game
  def initialize
    trap("INT") { exit 0 }
    @window = Window.new
    @registry = Registry.new

    @window.on_update do |input|
      receive(input)
      update
    end

    @window.on_draw do 
      draw
    end
  end

  def start!
    catch(:game_end) do
      window.show
    end
  rescue SystemExit
    puts "SystemExit"
  rescue Exception => ex
    puts ex
    puts ex.backtrace.first(5)
  ensure
    window.close
    puts "Closed 'gemfighter' at #{Time.now.strftime("%s")}"
  end

  protected
    attr_reader :registry
    attr_reader :window

    def receive(input)
      raise "Implement #handle_input in a base class"
    end

    def update
      raise "Implement #update in a base class"
    end

    def draw
      raise "Implement #draw in a base class"
    end
end

