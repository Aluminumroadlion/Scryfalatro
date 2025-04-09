
SMODS.Atlas { key = 'Jokers', path = 'Jokers.png', px = 71, py = 95 }

SMODS.current_mod.optional_features = function()
  return {retrigger_joker = true}
end

SMODS.Joker{
    key = 'jesters_hat',
    loc_txt = {
      name = 'Jester\'s Hat',
      text={
        "Sell this card to",
        "create two {C:attention,T:c_hanged_man}Hanged Man{}",
        "Tarot cards",
      },
    },
    loc_vars = function(self, info_queue, card)
      info_queue[#info_queue + 1] = G.P_CENTERS.c_hanged_man
    end,
    rarity = 2,
    cost = 7,
    blueprint_compat = false,
    eternal_compat = true,
    atlas = 'Jokers',
    pos = {x=1, y=0},
    calculate = function(self, card, context)
        if context.selling_self and not card.debuff and not context.blueprint then
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
      "full deck",
      "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)",
    }
  },
  config = {
    extra = {
      Xmult_gain = 0.75
    }
  },
  loc_vars = function(self, info_queue, card)
    local seal_cards = 0
    local Xmult_total = 1
    if G.playing_cards then
      for i=1,#G.playing_cards do
        if G.playing_cards[i].seal then seal_cards=seal_cards+1 end
      end
      Xmult_total = 1+card.ability.extra.Xmult_gain*seal_cards
    end
    return { vars = {
        card.ability.extra.Xmult_gain,
        Xmult_total,
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
      "Sell this card to add",
      "{C:chips}+#1#{} Chips",
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
      if context.selling_self and not card.debuff and G.GAME.blind.name ~= "" and not context.blueprint then
          SMODS.calculate_effect({
              message = localize{type='variable',key='a_chips',vars={card.ability.extra.chip_mod}},
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
      "This Joker gains",
      "{C:chips}-#1#{} Chips and {X:mult,C:white} X#2# {} Mult",
      "when {C:attention}Blind{} is selected",
      "{C:inactive}(Currently {C:chips}-#3#{C:inactive} Chips",
      "{C:inactive}and {X:mult,C:white} X#4# {C:inactive} Mult)",
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
        -card.ability.extra.chips_total,
        card.ability.extra.xmult_total,
    }}
  end,
  rarity = 2,
  cost = 7,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=4, y=0},
  calculate = function(self, card, context)
    if context.setting_blind and not card.debuff and not context.blueprint then
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
      "Retrigger all played cards",
      "if poker hand contains a",
      "{C:diamonds}Diamond{} card, {C:clubs}Club{} card,",
      "{C:hearts}Heart{} card, and {C:spades}Spade{} card",
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
      "Balance {C:blue}Chips{} and",
      "{C:red}Mult{} when calculating",
      "score for played hand",
    }
  },
  rarity = 3,
  cost = 10,
  blueprint_compat = false,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=6, y=0},
  calculate = function(self, card, context)
    if not card.debuffed and context.final_scoring_step and not context.blueprint then
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
  loc_txt = {
    name = 'Nicol Bolas',
    text={
      "Copies ability of",
      "{C:attention}Joker{} to the left {C:attention}twice{}",
    }
  },
  generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
    -- gen base UI
    SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
    -- add blueprint compat text
    card.ability.blueprint_compat_ui = card.ability.blueprint_compat_ui or ''; card.ability.blueprint_compat_check = nil
    desc_nodes[#desc_nodes + 1] = (card.area and card.area == G.jokers) and {
        {n=G.UIT.C, config={align = "bm", minh = 0.4}, nodes={
            {n=G.UIT.C, config={ref_table = card, align = "m", colour = G.C.JOKER_GREY, r = 0.05, padding = 0.06, func = 'blueprint_compat'}, nodes={
                {n=G.UIT.T, config={ref_table = card.ability, ref_value = 'blueprint_compat_ui',colour = G.C.UI.TEXT_LIGHT, scale = 0.32*0.8}},
            }}
        }}
    } or nil
  end,
  rarity = 4,
  cost = 20,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'Jokers',
  pos = {x=7, y=0},
  update = function(self, card, dt)
    if G.jokers then
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
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card and i-bolas_num>0 then
          other_joker = G.jokers.cards[i-bolas_num]
        end
      end
      if other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat then
        card.ability.blueprint_compat = 'compatible'
      else
          card.ability.blueprint_compat = 'incompatible'
      end
    end
  end,
  calculate = function(self, card, context)
    if not card.debuff and G.jokers.cards[1].config.center.key ~= "j_scryfalatro_nicol_bolas" then
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
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card and i-bolas_num>0 then
          other_joker = G.jokers.cards[i-bolas_num]
        end
      end
      local ret = nil
      ret = SMODS.blueprint_effect((context.blueprint and context.blueprint_card) or card, other_joker, context)
      if ret then return ret end
      if context.retrigger_joker_check and not context.retrigger_joker and context.other_card == card and bolas_num>0 then
        return {
            repetitions = 2^bolas_num-1,
            card = card,
        }
      end
    end
  end,
}

-- SMODS.Joker{
--   key = 'inverse_blueprint',
--   loc_txt = {
--     name = 'Inverse Blueprint',
--     text={
--       "Copies ability of {C:attention}Joker{}",
--       "to the left",
--     }
--   },
--   rarity = 3,
--   cost = 10,
--   blueprint_compat = true,
--   eternal_compat = true,
--   atlas = 'Jokers',
--   pos = {x=0, y=0},
--   calculate = function(self, card, context)
--     if not card.debuff and G.jokers.cards[1].config.center.key ~= "j_scryfalatro_inverse_blueprint" then
--       local other_joker = nil
--       for i = 1, #G.jokers.cards do
--           if G.jokers.cards[i] == card and i>1 then other_joker = G.jokers.cards[i-1] end
--       end
--       local ret = SMODS.blueprint_effect(card, other_joker, context)
--       if ret then return ret end
--     end
--   end,
-- }