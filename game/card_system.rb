module CardSystem
  def draw_card(entity)
    cs = entity[:card_state]

    card = cs[:deck].shift

    if cs[:contaminated]
      cs[:contaminated]= false
    else
      cooldown_weapon(cs)
    end

    unless card.present?
      puts "You have no cards to draw!"
      return
    end

    case card[:card_type]
    when :spell  
      if cs[:spell]
        puts "You already have a spell prepared!"
        cs[:deck].unshift(card)
      else
        puts "You drew #{card[:description]}!"
        cs[:spell] = card
      end
    when :item
      if cs[:item]
        puts "You're already holding an item!"
        cs[:deck].unshift(card)
      else
        puts "You drew #{card[:description]}!"
        cs[:item]= card
      end
    when :contamination
      puts "You are dizzy from magical energy!"
      cs[:contaminated]= true
    end
  end

  def play_weapon(entity)
    cs = entity[:card_state]
    return unless cs[:weapon]

    if cs[:weapon][:cooldown_timer] > 0
      puts "#{cs[:weapon][:description]} is still cooling down!"
    else
      puts "You struck with #{cs[:weapon][:description]}!"
      cs[:weapon][:cooldown_timer]= cs[:weapon][:cooldown]
    end
  end

  def cooldown_weapon(cs)
    return unless cs[:weapon]
    w = cs[:weapon]

    case
    when w[:cooldown_timer] == -1
      # no-op
    when w[:cooldown_timer] > 0 
      w[:cooldown_timer] -= 1
    when w[:cooldown_timer] == 0
      w[:cooldown_timer] -= 1
      puts "#{w[:description]} has cooled down!"
    when cs[:cooldown_timer] < -1
      # Should never happen, but let's be safe.
      STDERR.puts "Weapon cooldown got < 0... this shouldn't be happening!"
      cs[:cooldown_timer] = 0
    end
  end

  def play_spell(entity)
    cs = entity[:card_state]
    return unless cs[:spell]

    puts "You cast #{cs[:spell][:description]}!"
    cs[:deck] << cs[:spell]

    prng = Random.new
    n = cs[:spell][:contamination]

    n.times do |i|
      cs[:deck].insert(prng.rand(cs[:deck].length), {
        card_type: :contamination,
        tile_index: 8
      })
    end

    cs[:spell]= nil
  end

  def play_item(entity)
    cs = entity[:card_state]
    return unless cs[:item]

    item = cs[:item]
    puts "You used #{cs[:item][:description]}!"
    cs[:item]= nil
  end

  def replace_item(entity)
    cs = entity[:card_state]
    return unless cs[:item]

    cs[:deck] << cs[:item]
    puts "You put #{cs[:item][:description]} back into your pack."
    cs[:item]= nil
  end
end
