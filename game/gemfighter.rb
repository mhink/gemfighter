require 'game'

require 'bitmap'
require 'card_system'

class Gemfighter < Game
  WALLS = "111111111111111111111111110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000010000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011000000000000000000000001100000000000000000000000110000000000000000000000011111111111111111111111111"
  MAP_SIZE= Size[25,18]

 #  _____       _ _   _       _ _         
 # |_   _|     (_) | (_)     | (_)        
 #  | |  _ __  _| |_ _  __ _| |_ _______ 
 #  | | | '_ \| | __| |/ _` | | |_  / _ \
 # _| |_| | | | | |_| | (_| | | |/ /  __/
 #|_____|_| |_|_|\__|_|\__,_|_|_/___\___|
                                        
  def initialize(save_file=nil)
    super()

    @tiles = Gosu::Image.load_tiles(
      RES_DIR.join("tiled-icons-16x16.png").to_s, 
      16, 16,
      retro: true)

    @letters = Gosu::Image.load_tiles(
      RES_DIR.join("tiled-font-8x16.png").to_s,
      8, 16,
      retro: true)

    @tile_scale = Size[2,2]
    @grid_size = Size[32,32]
    @map_size = Size[25,19]
    @window = Window.new(size: Size[800,608])
    @window.on_input= self.method(:on_input)
    @window.on_update= self.method(:on_update)
    @window.on_draw= self.method(:on_draw)

    @prng = Random.new

    sword = {
      tile_index:     5,
      card_type:      :weapon,
      description:    "sword",
      cooldown:       3,
      cooldown_timer: -1
    }

    magic_missile = {
      tile_index:     6,
      card_type:      :spell,
      description:    "magic missile",
      contamination:  3,
    }

    meat = {
      tile_index:     4,
      card_type:      :item,
      description:    "hunk of meat",
    }

    @player = { 
      name: "Player",
      tile_index: 0,
      action:     nil,
      position:   Point[1,1],
      movement:   nil,
      card_state: {
        contaminated: true,
        weapon: sword,
        spell:  magic_missile,
        item:   meat,
        deck:    [],
      }
    }

    goblin = {
      name: "Goblin",
      tile_index: 1,
      action:     nil,
      position:   Point[3,3],
      movement:   nil,
      ai_method:  :goblin_ai,
    }

    walls = Bitmap.new(MAP_SIZE).from_s(WALLS).active_coords.map do |pt|
      {
        tile_index: 2,
        position:   pt,
        obstructing: true
      }
    end

    @movement   = [@player, goblin]
    @with_cards = [@player]
    @ai_method  = [goblin]
    @action     = [@player, goblin]
    @visible    = [@player, goblin, *walls]

    @map = {
      size:  Size[20,20],
      index: {
        @player[:position] => [@player],
         goblin[:position] => [ goblin],
      },
    }

    @map[:index].default_proc = Proc.new do |hash, key|
      hash[key]= []
    end

    walls.each do |entity|
      pos = entity[:position]
      @map[:index][pos] << entity
    end
  end

  def start
    @window.show
  end

  def stop
    @window.close
  end

  # _____                   _   
  #|_   _|                 | |  
  #  | |  _ __  _ __  _   _| |_ 
  #  | | | '_ \| '_ \| | | | __|
  # _| |_| | | | |_) | |_| | |_ 
  #|_____|_| |_| .__/ \__,_|\__|
  #            | |              
  #            |_|              
  def on_input
    @movement.each do |entity|
      entity[:movement]= nil
    end

    @player[:action]= case @window.active_input
    when "h" then [:move, Vector[-1,  0]]
    when "j" then [:move, Vector[ 0,  1]]
    when "k" then [:move, Vector[ 0, -1]]
    when "l" then [:move, Vector[ 1,  0]]
    when "y" then [:move, Vector[-1, -1]]
    when "b" then [:move, Vector[-1,  1]]
    when "u" then [:move, Vector[ 1, -1]]
    when "n" then [:move, Vector[ 1,  1]]
    when "g" then [:draw_card]
    when "f" then [:play_weapon]
    when "d" then [:play_spell]
    when "s" then [:play_item]
    when "a" then [:replace_item]
    when "q" then throw(:game_end)
    else
      return
    end

    @ai_method.each do |entity|
      entity[:action] = self.send(entity[:ai_method], entity)
    end

    @action.each do |entity|
      action, *args = entity[:action]
      next if action.nil?

      self.send(action, entity, *args)
      entity[:action]= nil
    end

    @movement.each do |entity|
      next if entity[:movement].nil?

      oldpos = entity[:position]
      newpos = entity[:position] + entity[:movement]

      next if out_of_bounds?(newpos)

      entities_at_pos = @map[:index][newpos]
      obstructed = entities_at_pos.any? do |entity|
        entity[:obstructing] == true
      end
      next if obstructed

      b = entity[:position]
      m = entity[:movement] / 5.0
      points = 6.times.map { |t| (b + (m*t)) }

      entity[:position]= newpos
      entity[:movement]= nil
      entity[:tween_points]= points
      @map[:index][oldpos].delete(entity)
      @map[:index][newpos].push(entity)
    end

    @animating = true
  end

  def on_update
    return !!@animating
  end

  def on_draw
    any_tweens = false

    @visible.each do |entity|
      pos = case
            when !entity.has_key?(:tween_points)
              entity[:position]
            when entity[:tween_points].empty?
              entity.delete(:tween_points)
              entity[:position]
            when entity[:tween_points].first.nil?
              entity[:tween_points].shift
              redo
            else
              any_tweens= true
              entity[:tween_points].shift
            end
      x, y   = (pos * @grid_size).to_a
      sx, sy = @tile_scale.to_a
      img    = @tiles[entity[:tile_index]]
      img.draw(x, y+32, 0, sx, sy)
    end

    if @player[:card_state][:weapon] 
      if @player[:card_state][:weapon][:cooldown_timer] == -1
        draw_tile(5, Point[0,0])
      else
        draw_tile(5, Point[0,0], 0x7fff_7f7f)
      end
    end

    if @player[:card_state][:spell] 
      draw_tile(@player[:card_state][:spell][:tile_index], Point[1,0])
    end

    if @player[:card_state][:item] 
      draw_tile(@player[:card_state][:item][:tile_index], Point[2,0])
    end

    @player[:card_state][:deck].each.with_index do |card, ix|
      draw_tile(card[:tile_index], Point[ix+4, 0])
    end

    @animating = any_tweens
  end

  private
    include CardSystem

    NUMBERS  = (0..9)
    CAPITALS = (32..74)
    LOWERS   = (96..137)
    PUNCT    = (160..184)
    SYMBOLS  = (192..211)

    MAPPINGS = {
      "0123456789" => NUMBERS ,
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ" => CAPITALS,
      "abcdefghijklmnopqrstuvwxyz" => LOWERS,
      "#%&@$.,!?:;'\"()[]*/\+-<=>" => PUNCT,
    }

    def to_char_tiles(str)
      indices = str.chars.map do |char|
        key = MAPPINGS.keys.find { |k| k.include? char }
        ix  = key.index(char)
        range = MAPPINGS[key]
        (range.first + ix)
      end

      indices.map do |ix|
        @letters[ix]
      end
    end

    def draw_tile(tile_ix, pt, color=0xffff_ffff)
      x, y   = (pt * @grid_size).to_a
      sx, sy = @tile_scale.to_a
      img    = @tiles[tile_ix]
      img.draw(x, y, 0, sx, sy, color)
    end

    def out_of_bounds?(pos)
      pos.x < 0 || 
      pos.y < 0 ||
      pos.x >= @map_size.x || 
      pos.y >= @map_size.y
    end

    def goblin_ai(entity)
      [
        [:move, Vector[-1,  0]],
        [:move, Vector[ 0,  1]],
        [:move, Vector[ 0, -1]],
        [:move, Vector[ 1,  0]],
        [:move, Vector[-1, -1]],
        [:move, Vector[-1,  1]],
        [:move, Vector[ 1, -1]],
        [:move, Vector[ 1,  1]],
      ][@prng.rand(8)]
    end

    def move(entity, vector)
      entity[:movement]= vector
    end
end
