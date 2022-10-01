class_name Modifiers

enum Rarity {
    COMMON,
    RARE,
    LEGENDARY
}

enum Effects {
    FREEZE,
    MARK,
    STUN,
    BURN,
    INTOXICATE,
    REACT,
    UNSTACK,
    STACK,
    LEECH
}

enum Gun {
    NONE,
    HOMING,
    LIGHTNING,
    QUICK_RELOAD,
    LARGE_MAGAZINE,
    BOTTOMLESS_MAGAZINE,
    SCATTERSHOT,
    CHAIN,
    LASER,
    EXPLOSIVE,
    SPEEDY,
    RAPID_FIRE,
    ONE_HIT_WONDER,
    LONG_RANGE,
    PIERCING,
    RADIAL,
    VAMPIRIC,
    FREEZING,
    MARKING,
    TRICK_SHOT,
    ASSASSIN,
    STACKING,
    IMPACT,
    LUCKY,
    STUNNING,
    HOT_SHOT,
    INTOXICATING,
    FRONT_LOADED,
    POWERFUL,
    REACTIVE,
    BLAZE_OF_GLORY,
    BULLET_EATER,
    RICOCHET,
    GROWING,
    BIG_SHOT
}

const DESCRIPTIONS: Dictionary = {
    Gun.NONE: "Well that isn't very exciting.",
    Gun.HOMING: "",
    Gun.LIGHTNING: "",
    Gun.QUICK_RELOAD: "",
    Gun.LARGE_MAGAZINE: "",
    Gun.BOTTOMLESS_MAGAZINE: "",
    Gun.SCATTERSHOT: "",
    Gun.CHAIN: "",
    Gun.LASER: "",
    Gun.EXPLOSIVE: "",
    Gun.SPEEDY: "",
    Gun.RAPID_FIRE: "",
    Gun.ONE_HIT_WONDER: "",
    Gun.LONG_RANGE: "",
    Gun.PIERCING: "",
    Gun.RADIAL: "",
    Gun.VAMPIRIC: "",
    Gun.FREEZING: "",
    Gun.MARKING: "",
    Gun.TRICK_SHOT: "",
    Gun.ASSASSIN: "",
    Gun.STACKING: "",
    Gun.IMPACT: "",
    Gun.LUCKY: "",
    Gun.STUNNING: "",
    Gun.HOT_SHOT: "May cause the target to catch on fire",
    Gun.INTOXICATING: "",
    Gun.FRONT_LOADED: "",
    Gun.POWERFUL: "",
    Gun.REACTIVE: "",
    Gun.BLAZE_OF_GLORY: "",
    Gun.BULLET_EATER: "",
    Gun.RICOCHET: "",
    Gun.GROWING: "",
    Gun.BIG_SHOT: ""
}

const RARITIES: Dictionary = {
    Gun.NONE: Rarity.COMMON,
    Gun.HOMING: Rarity.COMMON,
    Gun.LIGHTNING: Rarity.COMMON,
    Gun.QUICK_RELOAD: Rarity.COMMON,
    Gun.LARGE_MAGAZINE: Rarity.COMMON,
    Gun.BOTTOMLESS_MAGAZINE: Rarity.COMMON,
    Gun.SCATTERSHOT: Rarity.COMMON,
    Gun.CHAIN: Rarity.COMMON,
    Gun.LASER: Rarity.COMMON,
    Gun.EXPLOSIVE: Rarity.COMMON,
    Gun.SPEEDY: Rarity.COMMON,
    Gun.RAPID_FIRE: Rarity.COMMON,
    Gun.ONE_HIT_WONDER: Rarity.COMMON,
    Gun.LONG_RANGE: Rarity.COMMON,
    Gun.PIERCING: Rarity.COMMON,
    Gun.RADIAL: Rarity.COMMON,
    Gun.VAMPIRIC: Rarity.COMMON,
    Gun.FREEZING: Rarity.COMMON,
    Gun.MARKING: Rarity.COMMON,
    Gun.TRICK_SHOT: Rarity.COMMON,
    Gun.ASSASSIN: Rarity.COMMON,
    Gun.STACKING: Rarity.COMMON,
    Gun.IMPACT: Rarity.COMMON,
    Gun.LUCKY: Rarity.COMMON,
    Gun.STUNNING: Rarity.COMMON,
    Gun.HOT_SHOT: Rarity.COMMON,
    Gun.INTOXICATING: Rarity.COMMON,
    Gun.FRONT_LOADED: Rarity.COMMON,
    Gun.POWERFUL: Rarity.COMMON,
    Gun.REACTIVE: Rarity.COMMON,
    Gun.BLAZE_OF_GLORY: Rarity.COMMON,
    Gun.BULLET_EATER: Rarity.COMMON,
    Gun.RICOCHET: Rarity.COMMON,
    Gun.GROWING: Rarity.COMMON,
    Gun.BIG_SHOT: Rarity.COMMON
}
