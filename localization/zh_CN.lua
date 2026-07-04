return {
    descriptions = {
        Other = {
            card_x_mult = {
                text = {
                    "{X:mult,C:white} X#1#{} 倍率",
                },
            },
            card_no_rank_suit = {
                text = {
                    "无点数和花色",
                },
            },
        },
        Joker = {
            j_gen_eight_bit_detector = {
                name = '8bit探测器',
                text = {
                    '弃牌时改为从手牌中',
                    '随机弃掉{C:attention}#1#{}张牌',
                    '所有打出的牌按随机顺序',
                    '总共计分{C:attention}#2#{}次',
                },
            },
            j_gen_placeholder_1 = {
                name = '反逆之焰',
                text = {
                    '使用消耗牌修改手牌时',
                    '摧毁该牌并转化成',
                    '带有 {X:mult,C:white}X#1#{} 倍率和',
                    '{C:chips}+#2#{} 筹码的 {C:attention}石头牌{}',
                },
            },
            j_gen_in_tune = {
                name = '合拍',
                text = {
                    '重新触发打出的',
                    '{C:attention}第一张计分牌{}{C:attention}#1#{}次',
                    '重新触发所有{C:attention}留在手中的牌{}{C:attention}#1#{}次',
                    '重新触发所有其他{C:attention}小丑牌{}{C:attention}#1#{}次',
                },
            },
        },
    },
}
