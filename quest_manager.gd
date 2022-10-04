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
  QuestGlobals.RewardType.REWARD_MOD: 25,
  QuestGlobals.RewardType.REWARD_OTHER: 0, 
}

const quest_scn = preload("res://quest.tscn")
@onready var quest_container = $"/root/root/ui/top_right/quest_container"


# Pulls a rarity based on weights
func _get_next_quest_rarity():
  var weights = quest_rarity_weights.duplicate()
  var player = get_tree().get_first_node_in_group("player")
  if player:
    var lucky = false
    for upgrade in player.get_active_gun().UPGRADES:
      if upgrade == Modifiers.Gun.LUCKY:
        weights[QuestGlobals.Rarity.RARITY_COMMON] = int(weights[QuestGlobals.Rarity.RARITY_COMMON] * 0.6)
        weights[QuestGlobals.Rarity.RARITY_COMMON] = int(weights[QuestGlobals.Rarity.RARITY_RARE] * 0.8)
  var total = weights.values().reduce(func(i,accum): return accum + i)
  
  var rarity_penalty = 0  # rare quests penalize 1, legendary penalize 2. 
  for active_quest in active_quests:
    rarity_penalty += int(active_quest.quest_rarity)
  rarity_penalty += (3-total_quest_completion_count) if total_quest_completion_count <=3 else 0  # penalty on rarity for your first 3 quests
  var my_random_number = rng.randi_range(0, total-1) - rarity_penalty
  
  for rarity in weights:
    my_random_number -= weights[rarity]
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
  $"/root/root/ui/top_right/quest_container/press_x_to_upgrade/animation_player".play("pulse_text_color")
  rng.randomize()
  _sort_quests_by_rarity()
  _sort_rewards_by_type_by_rarity()
  
  for stat in QuestGlobals.StatTrack.values():
    stat_timers_active_status[stat] = false  
    if stat == QuestGlobals.StatTrack.STAT_DO_NOTHING:
      stat_timers_active_status[stat] = true
    if stat == QuestGlobals.StatTrack.STAT_HOLD_YOUR_BREATH:
      stat_timers_active_status[stat] = true
    if stat == QuestGlobals.StatTrack.STAT_DO_NOTHING:
      stat_timers_active_status[stat] = true      

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

const DEBUG_MODE = false
var debug_quest_index = 0

func _priority_quest():
  var sorted_rarity = range(len(QuestGlobals.Rarity))
  for iter_rarity in sorted_rarity:
    for priority_quest in quests_by_rarity[iter_rarity]:
      var avail = priority_quest.is_available.call()
      if (avail || avail== null) && priority_quest.priority_quest :
        var currently_active = false
        for active_quest in active_quests:
          if active_quest.quest_id == priority_quest.quest_id:
            currently_active = true
        if !currently_active:
          return [priority_quest, iter_rarity]
  return []
            
func _roll_new_quest():
  var rarity = _get_next_quest_rarity()
  var reward_type = _get_next_quest_reward_type()  
  
  var quest
  if DEBUG_MODE && false:
    quest = QuestGlobals.all_quests[debug_quest_index]
    debug_quest_index+=1
    if debug_quest_index >= len(QuestGlobals.all_quests):
      debug_quest_index = 0
    rarity = quest.quest_rarity.keys()[0]
  else:
   
    var priority_quests = _priority_quest()        
    if len(priority_quests) > 0:
      quest = priority_quests[0]
      if (quest.quest_uses_by_rarity.has(rarity) && quest.quest_uses_by_rarity[rarity] <= 0) || !quest.quest_rarity.has(rarity):      
       rarity = priority_quests[1] # default the rarity if we ran out of uses on the one we rolled or the rolled rarity is not supported
    else:  
      var safety_counter = 50
      while (true):
        safety_counter-=1
        if (safety_counter < 0):
          break
          
        quest = quests_by_rarity[rarity][rng.randi_range(0, len(quests_by_rarity[rarity])-1)]
        var avail = quest.is_available.call()
        if (avail || avail== null):
          var currently_active = false
          for active_quest in active_quests:
            if active_quest.quest_id == quest.quest_id:
              currently_active = true
              
          # if we dont already have this quest, finally break
          if (!currently_active):
            break;
        
    if quest.quest_uses_by_rarity.has(rarity):
      quest.quest_uses_by_rarity[rarity]-=1
      if quest.quest_uses_by_rarity[rarity]<=0:
        quests_by_rarity[rarity].erase(quest)
        
  var reward = rewards_by_type_by_rarity[rarity][reward_type][rng.randi_range(0, len(rewards_by_type_by_rarity[rarity][reward_type])-1)]
  
  var new_quest_scn = quest_scn.instantiate()
  
  quest_container.add_child(new_quest_scn)
  quest_container.move_child(new_quest_scn, 0)
 
  new_quest_scn.initialize(reward, quest.quest_id, rarity, quest.description, quest.quest_stat, quest.quest_rarity[rarity])
  active_quests.append(new_quest_scn)
  if stat_timers_active_status[quest.quest_stat]:
    new_quest_scn.quest_start_timer(quest.quest_stat)
  
  # remove excess children
  while (quest_container.get_child_count() - 1 > MAX_CONCURRENT_QUESTS):
    var removed_quest = quest_container.get_child(MAX_CONCURRENT_QUESTS)
    if (!removed_quest.is_completed):
      if DEBUG_MODE:
        quest_complete(removed_quest, removed_quest.reward)
      quest_count_progress(QuestGlobals.StatTrack.STAT_UNFINISHED_QUEST)
    active_quests.erase(removed_quest)
    quest_container.remove_child(removed_quest)
  
# Called every frame. 'delta' is the elapsed time since the previous frame.
var HYPER_BOOST_RATE = 5 # time travels at 5x speed when you have no quests left and 3x for the quest after
func _process(delta):
  # TODO: pausing / slower time, etc?
  spawn_rate_counter += delta * (HYPER_BOOST_RATE if hyper_speed_quest_accrual else 1)
  if quest_container.get_child_count() - 1 >= MAX_CONCURRENT_QUESTS:
    quest_container.get_child(MAX_CONCURRENT_QUESTS - 1).set_seconds_left(quest_spawn_rate-spawn_rate_counter)
    
  if (spawn_rate_counter >= quest_spawn_rate):
    spawn_rate_counter -= quest_spawn_rate
    _roll_new_quest()
    HYPER_BOOST_RATE -= 2
    if (HYPER_BOOST_RATE < 1):
      HYPER_BOOST_RATE = 1
      hyper_speed_quest_accrual = false
  
  $"/root/root/ui/top_right/quest_container/press_x_to_upgrade".visible = len(rewards_to_earn) > 0
  if (len(rewards_to_earn) > 0):
    var text = ""
    if len(rewards_to_earn) > 1:
      text = "%d rewards available!" % len(rewards_to_earn)
    else:
      text = "1 reward available"
    
    $"/root/root/ui/top_right/quest_container/press_x_to_upgrade/reward_available".text = text
    
    if Input.is_action_just_pressed("action"):
      _pausable_earn_reward()
  
  if DEBUG_MODE && Input.is_action_just_pressed("dash"):    
    _roll_new_quest()

func quest_count_progress(stat_track_id, amount = 1):
  var stats = find_cascading_stats(stat_track_id)
  stats.append(stat_track_id)
  for stat_track in stats:
    for quest_scn in active_quests:
      quest_scn.quest_count_progress(stat_track, amount)
  
# This is for stats that involve continuity (do __ without doing __)
func quest_reset_progress_count(stat_track_id):
  var stats = find_cascading_stats(stat_track_id)
  stats.append(stat_track_id)
  for stat_track in stats:
    for quest_scn in active_quests:
      quest_scn.quest_reset_progress_count(stat_track)

# For stats that involve duration
func quest_start_timer(stat_track_id):
  var stats = find_cascading_stats(stat_track_id)
  stats.append(stat_track_id)
  for stat_track in stats:
    stat_timers_active_status[stat_track] = true
    for quest_scn in active_quests:
      quest_scn.quest_start_timer(stat_track)
  
# If the duration does not need to be continuous
func quest_pause_timer(stat_track_id):
  var stats = find_cascading_stats(stat_track_id)
  stats.append(stat_track_id)
  for stat_track in stats:
    stat_timers_active_status[stat_track] = false
    for quest_scn in active_quests:
      quest_scn.quest_pause_timer(stat_track)
  
# For if the duration must be continous
func quest_reset_timer(stat_track_id):
  var stats = find_cascading_stats(stat_track_id)
  stats.append(stat_track_id)
  for stat_track in stats:
    stat_timers_active_status[stat_track] = false
    for quest_scn in active_quests:
      quest_scn.quest_reset_timer(stat_track)

func find_cascading_stats(stat_track_id):
  var cascading_stats = []
  match stat_track_id:
    QuestGlobals.StatTrack.STAT_RELOAD:
      if is_moving():
        cascading_stats.append(QuestGlobals.StatTrack.STAT_RELOAD_WHILE_MOVING)
      else:
        cascading_stats.append(QuestGlobals.StatTrack.STAT_RELOAD_WHILE_STATIONARY)
    QuestGlobals.StatTrack.STAT_KILL_ENEMY:
      if is_moving():
        cascading_stats.append(QuestGlobals.StatTrack.STAT_KILL_ENEMY_WHILE_MOVING)
      else:
        cascading_stats.append(QuestGlobals.StatTrack.STAT_KILL_ENEMY_WITHOUT_MOVING)
  return cascading_stats

var rewards_to_earn = []

func is_moving():
  return stat_timers_active_status[QuestGlobals.StatTrack.STAT_MOVE]
  
var total_quest_completion_count = 0
var hyper_speed_quest_accrual = false

func quest_complete(quest, reward):
  total_quest_completion_count += 1
  active_quests.erase(quest)
  rewards_to_earn.append(reward)
  $"/root/root/sfx/quest_complete".play()
  
  if len(active_quests)<= 0:
    hyper_speed_quest_accrual = true
  
  var random_rarity_to_increase_rate_of = randi_range(quest.quest_rarity, min(quest.quest_rarity+1, QuestGlobals.Rarity.RARITY_LEGENDARY)) # Add weights to the current tier or one tier higher
  quest_rarity_weights[random_rarity_to_increase_rate_of] += 1
  for i in range(randi_range(1,(MAX_CONCURRENT_QUESTS - len(active_quests)))):
    quest_rarity_weights[random_rarity_to_increase_rate_of] +=  randi_range(0, quest.quest_rarity)   # bonus for how many quests you currently have completed
  
  # TODO: Track the completion after reward from prior has been given? Right now this results in one reward being lost. If we add a slight delay here it should pause until after UI done?
  quest_count_progress(QuestGlobals.StatTrack.STAT_COMPLETE_QUEST)
  

# Earn 1 reward per process loop. Allowing time for the game to be paused for each individual reward
func _pausable_earn_reward():
  if (len(rewards_to_earn) <= 0):
    return
    
  var reward = rewards_to_earn[0]
  rewards_to_earn.remove_at(0)
  
  QuestGlobals.show_reward(reward, quest_rarity_weights)  
