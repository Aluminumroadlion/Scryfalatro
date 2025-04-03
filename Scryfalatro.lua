
SMODS.Atlas { key = 'Jokers', path = 'Jokers.png', px = 71, py = 95 }

SMODS.Joker{
    key = 'jesters_hat',
    loc_txt = {
      name = 'Jester\'s Hat',
      text={
        "Sell this joker to create",
        "two {C:attention,T:c_hanged_man}Hanged Man{} tarot",
        "cards",
      }
    },
    rarity = 2,
    cost = 7,
    blueprint_compat = false,
    eternal_compat = true,
    atlas = 'Jokers',
    pos = {x=1, y=0},
    calculate = function(self, card, context)
        if context.selling_self and not card.debuff then
          for i=1,2 do if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
              SMODS.add_card({key = 'c_hanged_man'})
          end end
        end
    end,
}

SMODS.Joker{
  key = 'imperialseal',
  loc_txt = {
    name = 'Imperial Seal',
    text={
      "{X:mult,C:white} X#1# {} Mult for each",
      "card with a {C:attention}seal{} in your",
      "deck",
    }
  },
  config = {
    extra = {
      Xmult_gain = 0.75
    }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = {
        card.ability.extra.Xmult_gain
    }}
  end,
  rarity = 3,
  cost = 8,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=2, y=0},
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.joker_main then
      local seal_cards = 0
      for i=1,#G.playing_cards do
        if G.playing_cards[i].seal then seal_cards=seal_cards+1 end
      end
      local Xmult_total = 1+card.ability.extra.Xmult_gain*seal_cards
      -- seal cards function
      return {
        message = localize{type='variable',key='a_xmult',vars={Xmult_total}},
        Xmult_mod = Xmult_total,
        colour = G.C.RED
      }
    end
  end,
}

SMODS.Joker{
  key = 'lightningbolt',
  loc_txt = {
    name = 'Lightning Bolt',
    text={
      "Sell this joker to add",
      "{C:chips}+#1#{} chips",
    }
  },
  config = {
      extra = {
        chip_mod = 500
      }
  },
  loc_vars = function(self, info_queue, card)
  return { vars = {
      card.ability.extra.chip_mod
  }}
  end,
  rarity = 1,
  cost = 3,
  blueprint_compat = false,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=3, y=0},
  calculate = function(self, card, context)
      if context.selling_self and not card.debuff and G.GAME.blind then
          SMODS.calculate_effect({
              message = "+"..card.ability.extra.chip_mod,
              colour = G.C.CHIPS
          }, card)
          G.GAME.chips = G.GAME.chips + card.ability.extra.chip_mod
      end
  end,
}

SMODS.Joker{
  key = 'cyclonic_rift',
  loc_txt = {
    name = 'Cyclonic Rift',
    text={
      "Gains {C:chips}-#1#{} Chips and {X:mult,C:white} X#2# {}",
      "Mult when blind selected",
    }
  },
  config = {
    extra = {
      chips_loss = 5,
      Xmult_gain = 1,
      chips_total = 0,
      xmult_total = 1,
    }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = {
        card.ability.extra.chips_loss,
        card.ability.extra.Xmult_gain,
    }}
  end,
  rarity = 2,
  cost = 7,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=4, y=0},
  calculate = function(self, card, context)
    if context.setting_blind and not card.debuff then
      card.ability.extra.chips_total = card.ability.extra.chips_total-card.ability.extra.chips_loss
      card.ability.extra.xmult_total = card.ability.extra.xmult_total+card.ability.extra.Xmult_gain
      return{
        message = localize('k_upgrade_ex')
      }
    end
    if context.cardarea == G.jokers and context.joker_main and card.ability.extra.xmult_total>1 then
      return {
        message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult_total}},
        Xmult_mod = card.ability.extra.xmult_total,
        chips = card.ability.extra.chips_total,
        colour = G.C.RED,
      }
    end
  end,
}

SMODS.Joker{
  key = 'birds',
  loc_txt = {
    name = 'Birds of Paradise',
    text={
      "Retrigger all played",
      "cards if poker hand",
      "contains a {C:diamonds}diamond{}",
      "{C:diamonds}card{}, {C:clubs}club card{},",
      "{C:hearts}heart card{}, and {C:spades}spade{}",
      "{C:spades}card{}"
    }
  },
  rarity = 2,
  cost = 7,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=5, y=0},
  calculate = function(self, card, context)
    if not card.debuff and context.cardarea == G.play and context.repetition and context.other_card then
      local suits = {
          ['Hearts'] = 0,
          ['Diamonds'] = 0,
          ['Spades'] = 0,
          ['Clubs'] = 0
      }
      for i = 1, #context.scoring_hand do
          if context.scoring_hand[i].ability.name ~= 'Wild Card' then
              if context.scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
              elseif context.scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
              elseif context.scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
              elseif context.scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
          end
      end
      for i = 1, #context.scoring_hand do
          if context.scoring_hand[i].ability.name == 'Wild Card' then
              if context.scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then suits["Hearts"] = suits["Hearts"] + 1
              elseif context.scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0  then suits["Diamonds"] = suits["Diamonds"] + 1
              elseif context.scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0  then suits["Spades"] = suits["Spades"] + 1
              elseif context.scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0  then suits["Clubs"] = suits["Clubs"] + 1 end
          end
      end
      if suits["Hearts"] > 0 and suits["Diamonds"] > 0 and suits["Spades"] > 0 and suits["Clubs"] > 0 then
        return{
          message = localize('k_again_ex'),
          repetitions = 1,
          card = card,
        }
      end
    end
  end,
}

SMODS.Joker{
  key = 'balance',
  loc_txt = {
    name = 'Balance',
    text={
      "Average chips and mult",
      "before scoring"
    }
  },
  rarity = 3,
  cost = 10,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=6, y=0},
  calculate = function(self, card, context)
    if not card.debuffed and context.final_scoring_step then
      local tot = hand_chips + mult
      hand_chips = mod_chips(math.floor(tot/2))
      mult = mod_mult(math.floor(tot/2))
			update_hand_text({ delay = 0 }, { mult = mult, chips = hand_chips })
			G.E_MANAGER:add_event(Event({
        func = (function()
            local text = localize('k_balanced')
            play_sound('gong', 0.94, 0.3)
            play_sound('gong', 0.94*1.5, 0.2)
            play_sound('tarot1', 1.5)
            ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
            ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
            attention_text({
                scale = 1.4, text = text, hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
            })
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blockable = false,
                blocking = false,
                delay =  4.3,
                func = (function() 
                        ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
                        ease_colour(G.C.UI_MULT, G.C.RED, 2)
                    return true
                end)
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                blockable = false,
                blocking = false,
                no_delete = true,
                delay =  6.3,
                func = (function() 
                    G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                    G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                    return true
                end)
            }))
            return true
        end)
      }))
    end
  end,
}

SMODS.Joker{
  key = 'nicol_bolas',
  name = 'Nicol Bolas',
  loc_txt = {
    name = 'Nicol Bolas',
    text={
      "Copies ability of {C:attention}Joker{}",
      "to the left, twice"
    }
  },
  rarity = 4,
  cost = 20,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=7, y=0},
  calculate = function(self, card, context)
    if not card.debuff then
      local other_joker = nil
      local bolas_num = 1
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then
          local consecutive_bolas = true
          while consecutive_bolas do
            if i-bolas_num>0 and G.jokers.cards[i-bolas_num].config.center.key == "j_scryfalatro_nicol_bolas" then
              bolas_num = bolas_num + 1
            else
              consecutive_bolas = false
            end
          end
        end
      end
      print(bolas_num)
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card and i>bolas_num then
          other_joker = G.jokers.cards[i-bolas_num]
        end
      end
      local ret = SMODS.blueprint_effect(card, other_joker, context)
      if ret then for i=1,2^bolas_num do SMODS.calculate_effect(ret, card) end end
    end
  end,
}