return {
    descriptions = {
        Other = {
            card_x_mult = {
                text = {
                    "{X:mult,C:white} X#1# {} Mult",
                },
            },
            card_no_rank_suit = {
                text = {
                    "no rank or suit",
                },
            },
        },
        Joker = {
            j_gen_eight_bit_detector = {
                name = '8-Bit Detector',
                text = {
                    'Discarding instead randomly discards',
                    '{C:attention}#1#{} cards from your hand',
                    'All played cards score',
                    'in a random order',
                    'for a total of {C:attention}#2#{} times',
                },
            },
            j_gen_placeholder_1 = {
                name = 'アポカリプスに反逆の焔を焚べろ',
                text = {
                    'When any consumable modifies a',
                    'held card, destroy it and create',
                    'a {C:attention}Stone Card{} with',
                    '{X:mult,C:white} X#1# {} Mult and {C:chips}+#2#{} chips',
                },
            },
            j_gen_in_tune = {
                name = 'In Tune',
                text = {
                    'Retrigger the first',
                    '{C:attention}scored card{} {C:attention}#1#{} time',
                    'Retrigger all {C:attention}held-in-hand cards{} {C:attention}#1#{} time',
                    'Retrigger all other {C:attention}Jokers{} {C:attention}#1#{} time',
                },
            },
        },
    },
}
