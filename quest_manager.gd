extends Node

var active_quests
var rng = RandomNumberGenerator.new()

# Affects rarity of incoming quests
var quest_rarity_weights : Dictionary = {
  QuestGlobals.Rarity.RARITY_COMMON: 50,
  QuestGlobals.Rarity.RARITY_RARE: 25,
  QuestGlobals.Rarity.RARITY_LEGENDARY: 5,
}

# Affects the distribution of incoming quest reward types
var quest_reward_type_weights : Dictionary = {
  QuestGlobals.RewardType.REWARD_GUN: 20,
  QuestGlobals.RewardType.REWARD_MOD: 40,
  QuestGlobals.RewardType.REWARD_OTHER: 30,
}

# Pulls a rarity based on weights
func _get_next_quest_rarity():
  var total = quest_rarity_weights.values.reduce(func(i,accum): return accum + i)
  var my_random_number = rng.randi_range(0, total-1)
  
  for rarity in quest_rarity_weights:
    my_random_number -= quest_rarity_weights[rarity]
    if my_random_number < 0:
      return rarity
      
  assert( false, "ERROR: Your Kevin is bad at coding. Recommend performing a factory reset.");
  
# Pulls a reward type based on weights
func _get_next_quest_reward_type():
  var total = quest_reward_type_weights.values.reduce(func(i,accum): return accum + i)
  var my_random_number = rng.randi_range(0, total-1)
  
  for reward_type in quest_reward_type_weights:
    my_random_number -= quest_reward_type_weights[reward_type]
    if my_random_number < 0:
      return reward_type
      
  assert( false, "ERROR: Your Kevin is bad at coding. Recommend performing a factory reset.");

# Called when the node enters the scene tree for the first time.
func _ready():
  rng.randomize()
  
  # TODO: need to load in all quests here and sort them by rarity
  
  # TODO: need to spawn a new quest every 10 seconds using above helpers
  
  # TODO: implement pass throughs below to tell all active quests about stat updates
  
  # TODO: set up hooks/signals for rewards
  
  # TODO: Start implementing rewards relating to quest system specifically
  


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func quest_count_progress(stat_track_id):
  pass
  
# This is for stats that involve continuity (do __ without doing __)
func quest_reset_progress_count(stat_track_id):
  pass


# TODO: quest manager needs to track which timers are active as well so that it can call start timer on brand new quests
# For stats that involve duration
func quest_start_timer(stat_track_id):
  pass
  
# If the duration does not need to be continuous
func quest_pause_timer(stat_track_id):
  pass
  
# For if the duration must be continous
func quest_stop_timer(stat_track_id):
  pass

# This is a callback when a quest deems itself completed.
func quest_completed(reward_type, reward_rarity):
  pass
