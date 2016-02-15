module CardSystem
  class << self
    def update_decks!
      Entity.find_by(:@is_card_state).each do |card_state|
        case card_state.action
        when :draw          then draw_card(card_state)
        when :weapon        then play_weapon(card_state)
        when :spell         then play_spell(card_state)
        when :use_item      then use_item(card_state)
        when :replace_item  then replace_item(card_state)
        end

        if card_state.contaminated
          card_state.contaminated= false
        else
          cooldown_weapon(card_state)
        end
        card_state.action= nil
      end
    end

    def draw_card(cs)
      card = cs.deck.shift

      if card.nil?
        puts "You have no cards to draw!"
        return
      end

      case card.card_type
      when :spell  
        if cs.spell
          puts "You already have a spell prepared!"
          cs.deck.unshift(card)
        else
          puts "You drew #{card.description}!"
          cs.spell = card
        end
      when :item
        if cs.item
          puts "You're already holding an item!"
          cs.deck.unshift(card)
        else
          puts "You drew #{card.description}!"
          cs.item = card
        end
      when :contamination
        puts "You are dizzy from magical energy!"
        cs.contaminated = true
      end
    end

    def play_weapon(cs)
      if cs.weapon.cooldown_timer > 0
        puts "#{cs.weapon.description} is still cooling down!"
      else
        puts "You struck with #{cs.weapon.description}!"
        cs.weapon.cooldown_timer = cs.weapon.cooldown
      end
    end

    def cooldown_weapon(cs)
      return unless cs.weapon
      w = cs.weapon

      case
      when w.cooldown_timer > 0 
        w.cooldown_timer -= 1
      when w.cooldown_timer == 0
        w.cooldown_timer -= 1
        puts "#{cs.weapon.description} has cooled down!"
      when w.cooldown_timer == -1
        # no-op
      when cs.cooldown_timer < -1
        # Should never happen, but let's be safe.
        STDERR.puts "Weapon cooldown got < 0... this shouldn't be happening!"
        cs.cooldown_timer = 0
      end
    end

    def play_spell(cs)
      cs.deck << cs.spell

      prng = Random.new
      n = cs.spell.contamination
      cs.spell.contamination.times do |i|
        contam = Entity.new(
          card_type: :contamination
        )
        cs.deck.insert(prng.rand(cs.deck.length), contam)
      end

      puts "You cast #{cs.spell.description}!"
      cs.spell= nil
    end

    def use_item(cs)
      item = cs.item
      puts "You used #{cs.item.description}!"
      cs.item= nil
    end

    def replace_item(cs)
      cs.deck << cs.item
      puts "You put #{cs.item.description} back into your pack."
      cs.item= nil
    end
  end
end
