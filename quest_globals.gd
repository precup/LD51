extends Node


class_name QuestGlobals
# Note: REWARD_OTHER includes quest system rewards and whatever other random awards we come up with, unless we want to split those out
enum RewardType {REWARD_GUN, REWARD_MOD, REWARD_OTHER}
enum Rarity {RARITY_COMMON, RARITY_RARE, RARITY_LEGENDARY}
enum StatTrack
{
  STAT_DO_NOTHING,
  STAT_KILL_ENEMY_WITHOUT_MOVING,
  STAT_KILL_WHILE_MOVING
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


var all_quests = [
    QuestData.New(StatTrack.STAT_DO_NOTHING,                    { Rarity.RARITY_COMMON: 5, Rarity.RARITY_RARE: 10, Rarity.RARITY_LEGENDARY: 20}, "Do nothing"),
    QuestData.New(StatTrack.STAT_KILL_ENEMY_WITHOUT_MOVING,     { Rarity.RARITY_COMMON: 5, Rarity.RARITY_RARE: 10, Rarity.RARITY_LEGENDARY: 20}, "Kills without moving"),
    QuestData.New(StatTrack.STAT_KILL_WHILE_MOVING,             { Rarity.RARITY_COMMON: 5, Rarity.RARITY_RARE: 10, Rarity.RARITY_LEGENDARY: 20}, "Kills while moving")
  ]


# TODO: Need an "all_rewards", probably using lambdas. Perhaps a reward handler too so that we can have a pop-up UI for user to read and accept/dismiss
