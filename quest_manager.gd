extends Node


var quests_by_rarity = {}
var rewards_by_type_by_rarity = {}
var stat_timers_active_status = {}
var active_quests = []
var rng = RandomNumberGenerator.new()

var quest_spawn_rate = 10.0 # 10s
var spawn_rate_counter = 30.0 # will spawn 3 quests to start
const MAX_CONCURRENT_QUESTS = 5

# Affects rarity of incoming quests
var quest_rarity_weights : Dictionary = {
  QuestGlobals.Rarity.RARITY_COMMON: 50, # was 50
  QuestGlobals.Rarity.RARITY_RARE: 25,
  QuestGlobals.Rarity.RARITY_LEGENDARY: 5,
}

# Affects the distribution of incoming quest reward types
var quest_reward_type_weights : Dictionary = {
  QuestGlobals.RewardType.REWARD_GUN: 20,
  QuestGlobals.RewardType.REWARD_MOD: 20,
  QuestGlobals.RewardType.REWARD_OTHER: 0, 
}
const quest_scn = preload("res://quest.tscn")
@onready var quest_container = $"/root/root/ui/top_right/quest_container"

# Pulls a rarity based on weights
func _get_next_quest_rarity():
  var total = quest_rarity_weights.values().reduce(func(i,accum): return accum + i)
  var my_random_number = rng.randi_range(0, total-1)
  
  for rarity in quest_rarity_weights:
    my_random_number -= quest_rarity_weights[rarity]
    if my_random_number < 0:
      return rarity
      
  assert( false, "ERROR: Your Kevin is bad at coding. Recommend performing a factory reset.");
  
# Pulls a reward type based on weights
func _get_next_quest_reward_type():
  var total = quest_reward_type_weights.values().reduce(func(i,accum): return accum + i)
  var my_random_number = rng.randi_range(0, total-1)
  
  for reward_type in quest_reward_type_weights:
    my_random_number -= quest_reward_type_weights[reward_type]
    if my_random_number < 0:
      return reward_type
      
  assert( false, "ERROR: Your Kevin is bad at coding. Recommend performing a factory reset.");

# Called when the node enters the scene tree for the first time.
func _ready():
  rng.randomize()
  _sort_quests_by_rarity()
  _sort_rewards_by_type_by_rarity()
  
  for stat in QuestGlobals.StatTrack.values():
    stat_timers_active_status[stat] = false  

func _sort_quests_by_rarity():
  for rarity in QuestGlobals.Rarity.values():
    quests_by_rarity[rarity] = []
    
  for quest in QuestGlobals.all_quests:
    for rarity in quest.quest_rarity:
      quests_by_rarity[rarity].append(quest)
      
func _sort_rewards_by_type_by_rarity():
  # Set up dictionary
  for rarity in QuestGlobals.Rarity.values():
    rewards_by_type_by_rarity[rarity] = {}
    for type in QuestGlobals.RewardType.values():
      rewards_by_type_by_rarity[rarity][type] = []
    
  for reward in QuestGlobals.all_rewards:
    rewards_by_type_by_rarity[reward.reward_rarity][reward.reward_type].append(reward)

func _roll_new_quest():
  var rarity = _get_next_quest_rarity()
  var reward_type = _get_next_quest_reward_type()  
  var quest = quests_by_rarity[rarity][rng.randi_range(0, len(quests_by_rarity[rarity])-1)]
  var reward = rewards_by_type_by_rarity[rarity][reward_type][rng.randi_range(0, len(rewards_by_type_by_rarity[rarity][reward_type])-1)]
  
  var new_quest_scn = quest_scn.instantiate()
  
  quest_container.add_child(new_quest_scn)
  quest_container.move_child(new_quest_scn, 0)
 
  new_quest_scn.initialize(reward, rarity, quest.description, quest.quest_stat, quest.quest_rarity[rarity])
  active_quests.append(new_quest_scn)
  if stat_timers_active_status[quest.quest_stat]:
    new_quest_scn.quest_start_timer(quest.quest_stat)
  
  # remove excess children
  while (quest_container.get_child_count() > MAX_CONCURRENT_QUESTS):
    var removed_quest = quest_container.get_child(MAX_CONCURRENT_QUESTS)
    active_quests.erase(removed_quest)
    quest_container.remove_child(removed_quest)
  
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  # TODO: pausing / slower time, etc?
  spawn_rate_counter += delta
  if quest_container.get_child_count() >= MAX_CONCURRENT_QUESTS:
    quest_container.get_child(MAX_CONCURRENT_QUESTS-1).set_seconds_left(quest_spawn_rate-spawn_rate_counter)
    
  if (spawn_rate_counter >= quest_spawn_rate):
    spawn_rate_counter -= quest_spawn_rate
    _roll_new_quest()
    
  if (len(rewards_to_earn) > 0):
    _pausable_earn_reward()

func quest_count_progress(stat_track_id, amount = 1):
  for quest_scn in active_quests:
    quest_scn.quest_count_progress(stat_track_id, amount)
  
# This is for stats that involve continuity (do __ without doing __)
func quest_reset_progress_count(stat_track_id):
  for quest_scn in active_quests:
    quest_scn.quest_reset_progress_count(stat_track_id)

# For stats that involve duration
func quest_start_timer(stat_track_id):
  stat_timers_active_status[stat_track_id] = true
  for quest_scn in active_quests:
    quest_scn.quest_start_timer(stat_track_id)
  
# If the duration does not need to be continuous
func quest_pause_timer(stat_track_id):
  stat_timers_active_status[stat_track_id] = false
  for quest_scn in active_quests:
    quest_scn.quest_pause_timer(stat_track_id)
  
# For if the duration must be continous
func quest_reset_timer(stat_track_id):
  stat_timers_active_status[stat_track_id] = false
  for quest_scn in active_quests:
    quest_scn.quest_reset_timer(stat_track_id)

var rewards_to_earn = []

func quest_complete(quest, reward):
  active_quests.erase(quest)
  rewards_to_earn.append(reward)
  
  # TODO: Track the completion after reward from prior has been given? Right now this results in one reward being lost. If we add a slight delay here it should pause until after UI done?
  quest_count_progress(QuestGlobals.StatTrack.STAT_COMPLETE_QUEST)
  

# Earn 1 reward per process loop. Allowing time for the game to be paused for each individual reward
func _pausable_earn_reward():
  if (len(rewards_to_earn) <= 0):
    return
    
  var reward = rewards_to_earn[0]
  rewards_to_earn.remove_at(0)
  
  QuestGlobals.show_reward(reward, quest_rarity_weights)  
