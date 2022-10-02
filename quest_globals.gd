extends Node


# Note: REWARD_OTHER includes quest system rewards and whatever other random awards we come up with, unless we want to split those out
enum RewardType {REWARD_GUN, REWARD_MOD, REWARD_OTHER}
enum Rarity {RARITY_COMMON, RARITY_RARE, RARITY_LEGENDARY}
enum StatTrack
{
  STAT_DO_NOTHING,
  STAT_KILL_ENEMY,
 # STAT_KILL_ENEMY_WITHOUT_MOVING,
  STAT_HIT_ENEMY,
 # STAT_KILL_WHILE_MOVING,
  STAT_FIRE_GUN,
  STAT_CONTINUOUSLY_FIRE,
  STAT_CONTINUOUSLY_TOUCH_WALL,
  STAT_COMPLETE_QUEST,
  STAT_GET_HIT,
  STAT_LOSE_HEARTS,
 # STAT_ADD_GUN_MODULE,
  STAT_KONAMI_CODE,
  STAT_KEY_PRESSED,
  STAT_IMANOK_CODE,
  STAT_FIRE_SHOT,
  STAT_RELOAD,
  STAT_APPLY_EFFECT,
  STAT_PICKUP_ITEM,
  STAT_HEAL,
  STAT_DASH
}

# If we decide quests should be limited to specific reward types, we can do so here.
class QuestData:
  var quest_stat : StatTrack
  var quest_rarity : Dictionary  # Mapping of Rarity to requirement int
  var description : String
  func _init(stat, rarity, desc):
    quest_stat = stat
    quest_rarity = rarity
    description = desc
    
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
  QuestData.new(StatTrack.STAT_DO_NOTHING, { Rarity.RARITY_COMMON: 5, Rarity.RARITY_RARE: 10, Rarity.RARITY_LEGENDARY: 20}, "Do nothing." ),
  QuestData.new(StatTrack.STAT_KILL_ENEMY, { Rarity.RARITY_COMMON: 3, Rarity.RARITY_RARE: 8, Rarity.RARITY_LEGENDARY: 15}, "Get kills." ),
#  QuestData.new(StatTrack.STAT_KILL_ENEMY_WITHOUT_MOVING, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 5, Rarity.RARITY_LEGENDARY: 10}, "Get kills without moving." ),
#  QuestData.new(StatTrack.STAT_KILL_WHILE_MOVING, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 5, Rarity.RARITY_LEGENDARY: 10}, "Get kills while moving constantly." ),
  QuestData.new(StatTrack.STAT_HIT_ENEMY, { Rarity.RARITY_COMMON: 10, Rarity.RARITY_RARE: 20, Rarity.RARITY_LEGENDARY: 50}, "Hit enemy." ),
  QuestData.new(StatTrack.STAT_APPLY_EFFECT, { Rarity.RARITY_RARE: 40, Rarity.RARITY_LEGENDARY: 100}, "Apply status effect to enemy." ),
  QuestData.new(StatTrack.STAT_FIRE_GUN, { Rarity.RARITY_COMMON: 10, Rarity.RARITY_RARE: 20, Rarity.RARITY_LEGENDARY: 40}, "Fire your gun." ),
  QuestData.new(StatTrack.STAT_FIRE_SHOT, { Rarity.RARITY_RARE: 40, Rarity.RARITY_LEGENDARY: 100}, "Fire bullets." ),
  QuestData.new(StatTrack.STAT_CONTINUOUSLY_FIRE, { Rarity.RARITY_COMMON: 10, Rarity.RARITY_RARE: 18, Rarity.RARITY_LEGENDARY: 25}, "Fire continuously." ),
  QuestData.new(StatTrack.STAT_CONTINUOUSLY_TOUCH_WALL, { Rarity.RARITY_COMMON: 10, Rarity.RARITY_RARE: 18, Rarity.RARITY_LEGENDARY: 25}, "Remain touching a wall." ),
  QuestData.new(StatTrack.STAT_COMPLETE_QUEST, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 2, Rarity.RARITY_LEGENDARY: 3}, "Complete other quest(s)." ),
  QuestData.new(StatTrack.STAT_GET_HIT, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 3, Rarity.RARITY_LEGENDARY: 5}, "Get hit." ),
  QuestData.new(StatTrack.STAT_LOSE_HEARTS, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 5, Rarity.RARITY_LEGENDARY: 10}, "Lose hearts." ),
#  QuestData.new(StatTrack.STAT_ADD_GUN_MODULE, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 3, Rarity.RARITY_LEGENDARY: 5}, "Add a module to your gun." ),
  QuestData.new(StatTrack.STAT_KONAMI_CODE, { Rarity.RARITY_RARE: 1}, "Enter the Konami code." ),
  QuestData.new(StatTrack.STAT_KEY_PRESSED, { Rarity.RARITY_COMMON: 30, Rarity.RARITY_RARE: 80, Rarity.RARITY_LEGENDARY: 160}, "Mash movement keys." ),
  QuestData.new(StatTrack.STAT_IMANOK_CODE, { Rarity.RARITY_LEGENDARY: 1}, "Enter the imanoK code." ),
  QuestData.new(StatTrack.STAT_RELOAD, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 4, Rarity.RARITY_LEGENDARY: 10}, "Reload your gun." ),
  QuestData.new(StatTrack.STAT_PICKUP_ITEM, { Rarity.RARITY_COMMON: 1, Rarity.RARITY_RARE: 3, Rarity.RARITY_LEGENDARY: 8}, "Pick up items." ),
  QuestData.new(StatTrack.STAT_HEAL, { Rarity.RARITY_COMMON: 2, Rarity.RARITY_RARE: 5, Rarity.RARITY_LEGENDARY: 10}, "Heal hearts." ),
  QuestData.new(StatTrack.STAT_DASH, { Rarity.RARITY_COMMON: 3, Rarity.RARITY_RARE: 6, Rarity.RARITY_LEGENDARY: 12}, "Dash." )
]

var all_rewards = [
  RewardData.new(RewardType.REWARD_GUN, Rarity.RARITY_COMMON , "", func (): show_reward(RewardType.REWARD_GUN, Rarity.RARITY_COMMON)),  # Call gun reward hookups
  RewardData.new(RewardType.REWARD_GUN, Rarity.RARITY_RARE , "", func (): show_reward(RewardType.REWARD_GUN, Rarity.RARITY_RARE)),  # Call gun reward hookups
  RewardData.new(RewardType.REWARD_GUN, Rarity.RARITY_LEGENDARY , "", func (): show_reward(RewardType.REWARD_GUN, Rarity.RARITY_LEGENDARY)),  # Call gun reward hookups
  
  RewardData.new(RewardType.REWARD_MOD, Rarity.RARITY_COMMON , "", func (): show_reward(RewardType.REWARD_MOD, Rarity.RARITY_COMMON)),  # Call mod reward hookups
  RewardData.new(RewardType.REWARD_MOD, Rarity.RARITY_RARE , "", func (): show_reward(RewardType.REWARD_MOD, Rarity.RARITY_RARE)),  # Call mod reward hookups
  RewardData.new(RewardType.REWARD_MOD, Rarity.RARITY_LEGENDARY , "", func (): show_reward(RewardType.REWARD_MOD, Rarity.RARITY_LEGENDARY)),  # Call mod reward hookups
  
  # TODO: Start implementing rewards relating to quest system specifically
  RewardData.new(RewardType.REWARD_OTHER, Rarity.RARITY_COMMON , "", func (): pass), 
  RewardData.new(RewardType.REWARD_OTHER, Rarity.RARITY_RARE , "", func (): pass), 
  RewardData.new(RewardType.REWARD_OTHER, Rarity.RARITY_LEGENDARY , "", func (): pass), 
]


func show_reward(reward_type, rarity):
  var reward_menu = get_tree().get_first_node_in_group("reward_menu")
  reward_menu.show_reward(reward_type, rarity)
