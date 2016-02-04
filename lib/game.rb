require 'entity'
require 'window'

class Game
  def initialize
    trap("INT") { exit 0 }
  end

  def start!
    catch(:game_end) do
      start
    end
  rescue SystemExit
    puts "SystemExit"
  rescue Exception => ex
    Entity.dump_debug!
    STDERR.puts ex
    STDERR.puts ex.backtrace.first(5)
  ensure
    stop
    puts "Closed 'gemfighter' at #{Time.now.strftime("%s")}"
  end

  protected
    def start
      # optional: implement in base class
    end

    def shutdown
      # optional: implement in base class
    end
end

