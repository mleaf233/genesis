local detector = rawget(_G, 'Genesis_8BitDetector') or {}
_G.Genesis_8BitDetector = detector

detector.key = 'j_gen_eight_bit_detector'
detector.discard_count = 8
detector.score_rounds = 8

local function copy_cards(cards)
    local copied = {}
    for i = 1, #cards do
        copied[i] = cards[i]
    end
    return copied
end

function detector.get_active_cards()
    if not SMODS or not SMODS.find_card then
        return {}
    end

    return SMODS.find_card(detector.key)
end

function detector.get_primary_card()
    return detector.get_active_cards()[1]
end

function detector.is_primary_card(card)
    return detector.get_primary_card() == card
end

function detector.is_active()
    return detector.get_primary_card() ~= nil
end

function detector.randomized_cards(cards, limit, seed_key)
    local randomized = copy_cards(cards or {})
    if #randomized > 1 then
        pseudoshuffle(randomized, pseudoseed(seed_key))
    end

    local count = math.min(limit or #randomized, #randomized)
    local selected = {}
    for i = 1, count do
        selected[i] = randomized[i]
    end
    return selected
end

function detector.build_score_sequence(cards, total_scores, seed_key)
    local randomized = detector.randomized_cards(cards, #cards, seed_key)
    local sequence = {}

    if #randomized == 0 then
        return sequence
    end

    for i = 1, total_scores do
        local index = ((i - 1) % #randomized) + 1
        sequence[i] = randomized[index]
    end

    return sequence
end

function detector.retarget_discard_highlight(hook)
    if hook or not detector.is_active() then
        return
    end

    if not G.hand or not G.hand.cards or not G.hand.highlighted or not G.hand.highlighted[1] then
        return
    end

    local targets = detector.randomized_cards(
        G.hand.cards,
        detector.discard_count,
        'gen_eight_bit_detector_discard'
    )

    if #targets == 0 then
        return
    end

    for i = #G.hand.highlighted, 1, -1 do
        local highlighted = G.hand.highlighted[i]
        highlighted:highlight(false)
        table.remove(G.hand.highlighted, i)
    end

    for i = 1, #targets do
        local target = targets[i]
        G.hand.highlighted[#G.hand.highlighted + 1] = target
        target:highlight(true)
    end
end

local function add_cards_played(card)
    if SMODS.has_no_rank(card) then
        return
    end

    G.GAME.cards_played[card.base.value].total =
        G.GAME.cards_played[card.base.value].total + 1

    if not SMODS.has_no_suit(card) then
        G.GAME.cards_played[card.base.value].suits[card.base.suit] = true
    end
end

local function trigger_debuff(card)
    G.GAME.blind.triggered = true
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            SMODS.juice_up_blind()
            return true
        end,
    }))
    card_eval_status_text(card, 'debuff')
end

function detector.should_use_random_scoring(context, scoring_hand)
    return detector.is_active()
        and context
        and context.cardarea == G.play
        and scoring_hand
        and #scoring_hand > 0
end

function detector.calculate_main_scoring(context, scoring_hand)
    local original_cardarea = context.cardarea
    local original_scoring_hand = context.scoring_hand
    local effective_scoring_hand = copy_cards(scoring_hand or {})

    if #effective_scoring_hand == 0 and original_cardarea and original_cardarea.cards then
        effective_scoring_hand = copy_cards(original_cardarea.cards)
    end

    context.scoring_hand = effective_scoring_hand

    local scorable_cards = {}
    for _, card in ipairs(effective_scoring_hand) do
        add_cards_played(card)

        if card.debuff then
            trigger_debuff(card)
        else
            scorable_cards[#scorable_cards + 1] = card
        end
    end

    local score_sequence = detector.build_score_sequence(
        scorable_cards,
        detector.score_rounds,
        'gen_eight_bit_detector_score'
    )

    for _, card in ipairs(score_sequence) do
        context.cardarea = G.play
        SMODS.score_card(card, context)
    end

    context.cardarea = original_cardarea
    context.scoring_hand = original_scoring_hand
end

SMODS.Joker {
    key = 'eight_bit_detector',
    config = {
        extra = {
            discard_count = detector.discard_count,
            score_rounds = detector.score_rounds,
        },
    },
    rarity = 3,
    cost = 8,
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    prefix_config = {
        atlas = false,
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.discard_count,
                card.ability.extra.score_rounds,
            },
        }
    end,

    calculate = function(self, card, context)
        if context.modify_scoring_hand
            and context.other_card
            and context.full_hand == G.play.cards
            and detector.is_primary_card(card)
        then
            return {
                add_to_hand = true,
            }
        end
    end,
}
