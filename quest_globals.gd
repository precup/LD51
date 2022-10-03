extends Node


@onready var quest_manager = $"/root/root/quest_manager"
@onready var player = $"/root/root/player"

# Note: REWARD_OTHER includes quest system rewards and whatever other random awards we come up with, unless we want to split those out
enum RewardType {REWARD_GUN, REWARD_MOD, REWARD_OTHER}
enum Rarity {RARITY_COMMON, RARITY_RARE, RARITY_LEGENDARY}
enum StatTrack
{
  STAT_DO_NOTHING,
  STAT_KILL_ENEMY,
  STAT_KILL_ENEMY_WITHOUT_MOVING, 
  STAT_HIT_ENEMY,
  STAT_KILL_ENEMY_WHILE_MOVING, 
  STAT_FIRE_GUN,
  STAT_CONTINUOUSLY_FIRE,
  STAT_CONTINUOUSLY_TOUCH_WALL,
  STAT_COMPLETE_QUEST,
  STAT_GET_HIT,
  STAT_LOSE_HEARTS,
  STAT_ADD_GUN_MODULE,  
  STAT_TRASH_GUN_MODULE, 
  STAT_REPLACE_GUN, 
  STAT_TRASH_GUN, 
  STAT_KONAMI_CODE, 
  STAT_KEY_PRESSED, 
  STAT_KEY_PRESSED_WHILE_MOUSE_DOWN,
  STAT_IMANOK_CODE, 
  STAT_FIRE_SHOT,
  STAT_RELOAD,
  STAT_APPLY_EFFECT,
  STAT_PICKUP_ITEM,
  STAT_HEAL,
  STAT_DASH,
  STAT_UNFINISHED_QUEST, 
  STAT_HOLD_YOUR_BREATH, 
  STAT_BREAK_OBJECT,
  STAT_RELOAD_WHILE_MOVING,
  STAT_RELOAD_WHILE_STATIONARY,
  STAT_MOVE,
}

const RARITY_COLORS_TRANSPARENT_BACK: Dictionary = {
  QuestGlobals.Rarity.RARITY_COMMON: Color("000000A4"),
  QuestGlobals.Rarity.RARITY_RARE: Color("161687A4"),
  QuestGlobals.Rarity.RARITY_LEGENDARY: Color("6A4108A4")
}

const RARITY_COLORS_BACK: Dictionary = {
  QuestGlobals.Rarity.RARITY_COMMON: Color("999999"),
  QuestGlobals.Rarity.RARITY_RARE: Color("4f4fff"),
  QuestGlobals.Rarity.RARITY_LEGENDARY: Color("cc8d35")
}

const RARITY_COLORS_TEXT: Dictionary = {
  QuestGlobals.Rarity.RARITY_COMMON: Color("FFFFFF"),
  QuestGlobals.Rarity.RARITY_RARE: Color("6ec2ff"),
  QuestGlobals.Rarity.RARITY_LEGENDARY: Color("ffbc5e")
}

# If we decide quests should be limited to specific reward types, we can do so here.
class QuestData:
  var quest_stat : StatTrack
  var quest_rarity : Dictionary  # Mapping of Rarity to requirement int
  var quest_uses_by_rarity : Dictionary # Mapping of rarity to uses left (if applicable)
  var priority_quest : bool
  var is_available : Callable
  var description : String
  var quest_id: int
  func _init(stat, rarity, desc, quest_uses:Dictionary={}, available:Callable=func(): return true, priority:bool = false):
    quest_stat = stat
    quest_rarity = rarity
    description = desc
    quest_uses_by_rarity = quest_uses
    is_available = available
    priority_quest = priority
    
class RewardData:
  var reward_type : RewardType
  var reward_rarity : Rarity
  var description : String
  var execute : Callable
  func _init(type, rarity, desc, callback):
    reward_type = type
    reward_rarity = rarity
    description = desc
    execute = callback

var all_quests = [
  QuestData.new(StatTrack.STAT_DO_NOTHING, { Rarity.RARITY_COMMON: 7, Rarity.RARITY_RARE: 15, Rarity.RARITY_LEGENDARY: 25}, "Do nothing.", { Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 1} ),
  QuestData.new(StatTrack.STAT_KILL_ENEMY, { Rarity.RARITY_COMMON: 3, Rarity.RARITY_RARE: 8, Rarity.RARITY_LEGENDARY: 15}, "Get kills." ),
  QuestData.new(StatTrack.STAT_KILL_ENEMY, { Rarity.RARITY_COMMON: 1}, "Kill an enemy.", {Rarity.RARITY_COMMON: 1}, func():return is_enemy_near(), true ),
  QuestData.new(StatTrack.STAT_BREAK_OBJECT, { Rarity.RARITY_COMMON: 1}, "Break an object.", {Rarity.RARITY_COMMON: 1}, func():return is_breakable_near(), true ),
  QuestData.new(StatTrack.STAT_BREAK_OBJECT, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Break objects.", {Rarity.RARITY_COMMON: 1}, func():return is_breakable_near()),
  QuestData.new(StatTrack.STAT_KILL_ENEMY_WITHOUT_MOVING, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 5, Rarity.RARITY_LEGENDARY: 10}, "Get kills without moving.",{}, func():return is_enemy_near() && have_completed_x_quests(4)  ),
  QuestData.new(StatTrack.STAT_KILL_ENEMY_WHILE_MOVING, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 5, Rarity.RARITY_LEGENDARY: 10}, "Get kills while moving constantly.",{}, func():return is_enemy_near() && have_completed_x_quests(4)  ),
  QuestData.new(StatTrack.STAT_MOVE, { Rarity.RARITY_COMMON: 10, Rarity.RARITY_RARE: 20, Rarity.RARITY_LEGENDARY: 35}, "Move." ),
  QuestData.new(StatTrack.STAT_HIT_ENEMY, { Rarity.RARITY_COMMON: 10, Rarity.RARITY_RARE: 20, Rarity.RARITY_LEGENDARY: 50}, "Hit enemy.", {}, func():return is_enemy_near() ),
  QuestData.new(StatTrack.STAT_APPLY_EFFECT, { Rarity.RARITY_RARE: 40, Rarity.RARITY_LEGENDARY: 100}, "Apply status effect to enemy.", {}, func():return is_enemy_near() && have_completed_x_quests(4) ),
  QuestData.new(StatTrack.STAT_FIRE_GUN, { Rarity.RARITY_COMMON: 15, Rarity.RARITY_RARE: 30, Rarity.RARITY_LEGENDARY: 60}, "Fire your gun." ),
  QuestData.new(StatTrack.STAT_FIRE_SHOT, { Rarity.RARITY_RARE: 100, Rarity.RARITY_LEGENDARY: 200}, "Fire bullets." ),
  QuestData.new(StatTrack.STAT_CONTINUOUSLY_FIRE, { Rarity.RARITY_COMMON: 10, Rarity.RARITY_RARE: 18, Rarity.RARITY_LEGENDARY: 25}, "Fire continuously." ),
  QuestData.new(StatTrack.STAT_CONTINUOUSLY_TOUCH_WALL, { Rarity.RARITY_COMMON: 5, Rarity.RARITY_RARE: 10, Rarity.RARITY_LEGENDARY: 20}, "Continuously touch a wall.", { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1} ),
  QuestData.new(StatTrack.STAT_COMPLETE_QUEST, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Complete other quest(s).", { Rarity.RARITY_RARE: 1 } ),
  QuestData.new(StatTrack.STAT_GET_HIT, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 3, Rarity.RARITY_LEGENDARY: 5}, "Get hit.", { Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return is_hazard_near()  ),
  QuestData.new(StatTrack.STAT_LOSE_HEARTS, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 5, Rarity.RARITY_LEGENDARY: 10}, "Lose hearts.", { Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return is_hazard_near()  ),
  QuestData.new(StatTrack.STAT_ADD_GUN_MODULE, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Add module(s) to your gun.", { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(3) ),
  QuestData.new(StatTrack.STAT_TRASH_GUN_MODULE, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Trash module(s).", { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(7) ),
  QuestData.new(StatTrack.STAT_REPLACE_GUN, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Get new gun(s).", { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(3) ),
  QuestData.new(StatTrack.STAT_TRASH_GUN, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Trash gun(s).", { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(7) ),
  QuestData.new(StatTrack.STAT_KONAMI_CODE, { Rarity.RARITY_RARE: 1}, "Enter the Konami code.", { Rarity.RARITY_RARE: 1}, func():return have_completed_x_quests(15) ),
  QuestData.new(StatTrack.STAT_KEY_PRESSED, { Rarity.RARITY_COMMON: 30, Rarity.RARITY_RARE: 80, Rarity.RARITY_LEGENDARY: 160}, "Mash movement keys." ),
  QuestData.new(StatTrack.STAT_KEY_PRESSED_WHILE_MOUSE_DOWN, { Rarity.RARITY_COMMON: 30, Rarity.RARITY_RARE: 80, Rarity.RARITY_LEGENDARY: 160}, "Mash movement keys, while shooting." ),
  QuestData.new(StatTrack.STAT_IMANOK_CODE, { Rarity.RARITY_LEGENDARY: 1}, "Enter the imanoK code.", { Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(10) ),
  QuestData.new(StatTrack.STAT_RELOAD, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 4, Rarity.RARITY_LEGENDARY: 10}, "Reload your gun." ),
  QuestData.new(StatTrack.STAT_RELOAD_WHILE_STATIONARY, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 3, Rarity.RARITY_LEGENDARY: 7}, "Reload your gun while standing still.", {}, func():return have_completed_x_quests(15) ),
  QuestData.new(StatTrack.STAT_RELOAD_WHILE_MOVING, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 4, Rarity.RARITY_LEGENDARY: 8}, "Reload your gun while moving.", {}, func():return have_completed_x_quests(15) ),
  QuestData.new(StatTrack.STAT_PICKUP_ITEM, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 4}, "Pick up items.",{}, func():return is_pickup_near() ),
  QuestData.new(StatTrack.STAT_HEAL, { Rarity.RARITY_RARE: 3, Rarity.RARITY_LEGENDARY: 5}, "Heal hearts.", {}, func():return have_completed_x_quests(5)),
  QuestData.new(StatTrack.STAT_DASH, { Rarity.RARITY_COMMON: 3, Rarity.RARITY_RARE: 6, Rarity.RARITY_LEGENDARY: 12}, "Dash." ),
  QuestData.new(StatTrack.STAT_UNFINISHED_QUEST, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Let unfinished quest(s) expire.", { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(2) && have_x_active_quests(3), true ),
  QuestData.new(StatTrack.STAT_HOLD_YOUR_BREATH, { Rarity.RARITY_RARE: 15, Rarity.RARITY_LEGENDARY: 30}, "Hold your breath!", {Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(5)),
  QuestData.new(StatTrack.STAT_HOLD_YOUR_BREATH, { Rarity.RARITY_LEGENDARY: 1}, "Be a cutie!", {Rarity.RARITY_RARE: 1, Rarity.RARITY_LEGENDARY: 1}, func():return have_completed_x_quests(5)),
  QuestData.new(StatTrack.STAT_HOLD_YOUR_BREATH, { Rarity.RARITY_RARE: 5}, "Enter your mother's maiden name!", {Rarity.RARITY_RARE: 1}, func():return have_completed_x_quests(5)),  
]

func _ready():
  for i in range (len(all_quests)):
    all_quests[i].quest_id = i

var all_rewards = [
  RewardData.new(RewardType.REWARD_GUN, Rarity.RARITY_COMMON , "", func (): pass),  # No specific call-back needed. all handled by show_rward
  RewardData.new(RewardType.REWARD_GUN, Rarity.RARITY_RARE , "", func (): pass),  
  RewardData.new(RewardType.REWARD_GUN, Rarity.RARITY_LEGENDARY , "", func (): pass),  
  
  RewardData.new(RewardType.REWARD_MOD, Rarity.RARITY_COMMON , "", func (): pass),  
  RewardData.new(RewardType.REWARD_MOD, Rarity.RARITY_RARE , "", func (): pass),  
  RewardData.new(RewardType.REWARD_MOD, Rarity.RARITY_LEGENDARY , "", func (): pass),  
  
  # TODO: Start implementing rewards relating to quest system specifically
  RewardData.new(RewardType.REWARD_OTHER, Rarity.RARITY_COMMON , "", func (): pass), # Call-backs will be needed here eventually
  RewardData.new(RewardType.REWARD_OTHER, Rarity.RARITY_RARE , "", func (): pass), 
  RewardData.new(RewardType.REWARD_OTHER, Rarity.RARITY_LEGENDARY , "", func (): pass), 
  
  # sort your quests by rarity
]

func show_reward(reward, base_rarity_weights):
  var reward_menu = get_tree().get_first_node_in_group("reward_menu")
  
  # TODO: when passing REWARD_OTHER through here we may need to handle it separately. Unsure how callbacks will work
  reward_menu.show_reward(reward.reward_type, reward.reward_rarity, base_rarity_weights)

const NEARBY_THRESH = 1800
func is_enemy_near():
  var nodes = get_tree().get_nodes_in_group("enemies")
  var player_position = player.global_transform.origin
  for node in nodes:
    var dist = player_position.distance_to(node.global_transform.origin)
    if dist < NEARBY_THRESH * 4:
      return true
  return false
  
func is_hazard_near():
  var nodes = get_tree().get_nodes_in_group("hazard")
  var player_position = player.global_transform.origin
  for node in nodes:
    var dist = player_position.distance_to(node.global_transform.origin)
    if dist < NEARBY_THRESH * 2:
      return true
  return is_enemy_near()
  
func have_completed_x_quests(x):
  return x <= quest_manager.total_quest_completion_count
  
func have_x_active_quests(x):
  return x <= len(quest_manager.active_quests)
  
func is_breakable_near():
  var nodes = get_tree().get_nodes_in_group("destructible")
  var player_position = player.global_transform.origin
  for node in nodes:
    var dist = player_position.distance_to(node.global_transform.origin)
    if dist < NEARBY_THRESH:
      return true
  return false
  
func is_pickup_near():
  var nodes = get_tree().get_nodes_in_group("pickups")
  var player_position = player.global_transform.origin
  for node in nodes:
    var dist = player_position.distance_to(node.global_transform.origin)
    if dist < NEARBY_THRESH:
      return true
  return false
