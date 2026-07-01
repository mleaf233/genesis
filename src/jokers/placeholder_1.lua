SMODS.Joker {
    key = 'placeholder_1',
    config = {
        extra = {
            x_mult = 2,
            chips = 50,
        },
    },
    rarity = 2,
    cost = 6,
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    prefix_config = {
        atlas = false,
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        return {
            vars = {
                card.ability.extra.x_mult,
                card.ability.extra.chips,
            },
        }
    end,

    calculate = function(self, card, context)
        if not context.using_consumeable then return nil end

        local used = context.consumeable
        if not used then return nil end

        local modifies =
            used.ability.consumeable.mod_conv
            or used.ability.consumeable.suit_conv
            or used.ability.name == 'Strength'
            or used.ability.name == 'Death'
            or used.ability.name == 'Aura'
            or used.ability.name == 'Deja Vu'
            or used.ability.name == 'Trance'
            or used.ability.name == 'Medium'
            or used.ability.name == 'Talisman'

        if not modifies then return nil end
        if not G.hand.highlighted or #G.hand.highlighted == 0 then return nil end

        local targets = {}
        for i = 1, #G.hand.highlighted do
            targets[i] = G.hand.highlighted[i]
        end

        -- 等待消耗品所有排队动画执行完后，将每张牌变为石头牌 + X2
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, t in ipairs(targets) do
                    -- 抖动+闪烁→"自毁"视觉
                    t:juice_up(0.6, 0.5)
                end

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        for _, t in ipairs(targets) do
                            -- 变形为石头牌（set_ability 会重置 ability.x_mult 为 1）
                            t:set_ability(G.P_CENTERS.m_stone)
                            -- set_ability 之后覆盖 x_mult 为 X2
                            t.ability.x_mult = card.ability.extra.x_mult
                            -- 重新高亮显示
                            t:juice_up(0.4, 0.3)
                        end
                        return true
                    end
                }))
                return true
            end
        }))

        return {
            message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.x_mult } },
            colour = G.C.SECONDARY_SET.Enhanced,
        }
    end,
}
