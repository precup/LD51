class_name Modifiers

enum Rarity {
  COMMON,
  RARE,
  LEGENDARY
}

enum Effect {
  FREEZE,
  MARK,
  STUN,
  BURN,
  INTOXICATE,
  REACT,
  UNSTACK,
  STACK,
  LEECH,
  RETURN,
  IMPACT,
  EXPLODE,
  TRICK_SHOT,
  CHAIN,
  GROW
}

enum Gun {
  NONE,
  HOMING,
  QUICK_RELOAD,
  LARGE_MAGAZINE,
  BOTTOMLESS_MAGAZINE,
  SCATTERSHOT,
  CHAIN,
  EXPLOSIVE,
  SPEEDY,
  RAPID_FIRE,
  ONE_HIT_WONDER,
  PIERCING,
  RADIAL,
  VAMPIRIC,
  FREEZING,
  MARKING,
  TRICK_SHOT,
  RAINBOW,
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
  BIG_SHOT,
  RETURNING
}

const DESCRIPTIONS: Dictionary = {
  Gun.NONE: "Well that isn't very exciting...",
  Gun.HOMING: "This one doesn't work yet",
  Gun.QUICK_RELOAD: "+100% reload speed",
  Gun.LARGE_MAGAZINE: "+100% magazine size",
  Gun.BOTTOMLESS_MAGAZINE: "Never reload again!",
  Gun.SCATTERSHOT: "Fire a spread of weaker spells",
  Gun.CHAIN: "Hitting an enemy causes a spell echo",
  Gun.EXPLOSIVE: "Damages everyone within a radius",
  Gun.SPEEDY: "Spells travel twice as fast",
  Gun.RAPID_FIRE: "+100% fire rate",
  Gun.ONE_HIT_WONDER: "Fire your entire magazine in one shot for half damage!",
  Gun.PIERCING: "Spells pierce through an additional enemy",
  Gun.RADIAL: "Fire spells all around you",
  Gun.VAMPIRIC: "Dealing damage has a chance to heal you",
  Gun.FREEZING: "Slows enemies",
  Gun.MARKING: "Double damage, but the damage doesn't occur until a second wand shoots them",
  Gun.TRICK_SHOT: "Spells deal triple damage if you're aiming away when they hit",
  Gun.RAINBOW: "Fire a stream of rainbow spells",
  Gun.STACKING: "Hit the same target without missing for extra damage",
  Gun.IMPACT: "Pushes enemies back",
  Gun.LUCKY: "High rarity quests are more common",
  Gun.STUNNING: "Dealing damage has a chance to stun enemies",
  Gun.HOT_SHOT: "May cause the target to catch on fire",
  Gun.INTOXICATING: "This one doesn't work yet",
  Gun.FRONT_LOADED: "Double damage, but enemies build tolerance to your shots",
  Gun.POWERFUL: "Twice the damage, but half the speed",
  Gun.REACTIVE: "Deal extra damage for every status effect on an enemy",
  Gun.BLAZE_OF_GLORY: "Deal triple damage if below 30% health",
  Gun.BULLET_EATER: "This one doesn't work yet",
  Gun.RICOCHET: "Spells bounce off a wall an additional time",
  Gun.GROWING: "Spells grow as they fly",
  Gun.BIG_SHOT: "Larger spells",
  Gun.RETURNING: "Hitting an enemy loads a spell into your magazine"
}

const NAMES: Dictionary = {
  Gun.NONE: "Empty",
  Gun.HOMING: "Homing",
  Gun.QUICK_RELOAD: "Quick Reload",
  Gun.LARGE_MAGAZINE: "Large Magazine",
  Gun.BOTTOMLESS_MAGAZINE: "Bottomless Magazine",
  Gun.SCATTERSHOT: "Scattershot",
  Gun.CHAIN: "Chain",
  Gun.EXPLOSIVE: "Explosive",
  Gun.SPEEDY: "Speedy",
  Gun.RAPID_FIRE: "Rapid Fire",
  Gun.ONE_HIT_WONDER: "One Hit Wonder",
  Gun.PIERCING: "Piercing",
  Gun.RADIAL: "Radial",
  Gun.VAMPIRIC: "Vampiric",
  Gun.FREEZING: "Freezing",
  Gun.MARKING: "Marking",
  Gun.TRICK_SHOT: "Trick Shot",
  Gun.RAINBOW: "Rainbow",
  Gun.STACKING: "Stacking",
  Gun.IMPACT: "Impact",
  Gun.LUCKY: "Lucky",
  Gun.STUNNING: "Stunning",
  Gun.HOT_SHOT: "Hot Shot",
  Gun.INTOXICATING: "Intoxicating",
  Gun.FRONT_LOADED: "Front Loaded",
  Gun.POWERFUL: "Powerful",
  Gun.REACTIVE: "Reactive",
  Gun.BLAZE_OF_GLORY: "Blaze of Glory",
  Gun.BULLET_EATER: "Bullet Eater",
  Gun.RICOCHET: "Ricochet",
  Gun.GROWING: "Growing",
  Gun.BIG_SHOT: "Big Shot",
  Gun.RETURNING: "Returning"
}

const RARITIES: Dictionary = {
  Gun.NONE: Rarity.COMMON,
  
  Gun.QUICK_RELOAD: Rarity.COMMON,
  Gun.LARGE_MAGAZINE: Rarity.COMMON,
  Gun.SPEEDY: Rarity.COMMON,
  Gun.PIERCING: Rarity.COMMON,
  Gun.STACKING: Rarity.COMMON,
  Gun.IMPACT: Rarity.COMMON,
  Gun.LUCKY: Rarity.COMMON,
  Gun.POWERFUL: Rarity.COMMON,
  Gun.RICOCHET: Rarity.COMMON,
  Gun.BIG_SHOT: Rarity.COMMON,
  
  Gun.VAMPIRIC: Rarity.RARE,
  Gun.FREEZING: Rarity.RARE,
  Gun.MARKING: Rarity.RARE,
  Gun.REACTIVE: Rarity.RARE,
  Gun.STUNNING: Rarity.RARE,
  Gun.HOT_SHOT: Rarity.RARE,
  Gun.SCATTERSHOT: Rarity.RARE,
  Gun.CHAIN: Rarity.RARE,
  Gun.INTOXICATING: Rarity.RARE,
  Gun.RAPID_FIRE: Rarity.RARE,
  Gun.FRONT_LOADED: Rarity.RARE,
  Gun.EXPLOSIVE: Rarity.RARE,
  Gun.HOMING: Rarity.RARE,
  Gun.BLAZE_OF_GLORY: Rarity.RARE,
  
  Gun.TRICK_SHOT: Rarity.LEGENDARY,
  Gun.RAINBOW: Rarity.LEGENDARY,
  Gun.BOTTOMLESS_MAGAZINE: Rarity.LEGENDARY,
  Gun.BULLET_EATER: Rarity.LEGENDARY,
  Gun.ONE_HIT_WONDER: Rarity.LEGENDARY,
  Gun.GROWING: Rarity.LEGENDARY,
  Gun.RADIAL: Rarity.LEGENDARY,
  Gun.RETURNING: Rarity.LEGENDARY
}
