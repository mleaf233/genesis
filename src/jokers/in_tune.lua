SMODS.Joker {
    key = 'in_tune',
    config = {
        extra = {
            repetitions = 1,
        },
    },
    rarity = 3,
    cost = 8,
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    prefix_config = {
        atlas = false,
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.repetitions,
            },
        }
    end,

    calculate = function(self, card, context)
        local repetitions = card.ability.extra.repetitions

        if context.repetition
            and context.cardarea == G.play
            and context.scoring_hand
            and context.other_card == context.scoring_hand[1] then
            return {
                message = localize('k_again_ex'),
                repetitions = repetitions,
                card = card,
            }
        end

        local has_held_effect =
            context.card_effects
            and (
                next(context.card_effects[1] or {})
                or #context.card_effects > 1
            )

        if context.repetition
            and context.cardarea == G.hand
            and has_held_effect then
            return {
                message = localize('k_again_ex'),
                repetitions = repetitions,
                card = card,
            }
        end

        if context.retrigger_joker_check
            and not context.retrigger_joker
            and not (context.other_context and context.other_context.retrigger_joker)
            and context.other_card
            and context.other_card ~= card
            and context.other_card.ability
            and context.other_card.ability.set == 'Joker' then
            return {
                message = localize('k_again_ex'),
                repetitions = repetitions,
                card = card,
            }
        end
    end,
}
