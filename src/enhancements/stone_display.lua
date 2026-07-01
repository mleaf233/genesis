-- 接管石头牌（m_stone），在悬停提示中条件显示 Xmult
SMODS.Enhancement:take_ownership('m_stone', {
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        -- 筹码显示
        local bonus = (specific_vars and specific_vars.bonus_chips) or self.config.bonus or 50
        localize { type = 'other', key = 'card_extra_chips', nodes = desc_nodes, vars = { bonus } }

        -- X2 倍率显示（仅当卡片实例有 x_mult > 1 时）
        if card and card.ability and card.ability.x_mult and card.ability.x_mult > 1 then
            localize { type = 'other', key = 'card_x_mult', nodes = desc_nodes, vars = { card.ability.x_mult } }
        end

        -- 无点数和花色
        localize { type = 'other', key = 'card_no_rank_suit', nodes = desc_nodes }
    end,
})
