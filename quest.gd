extends Node

class_name Quest

var reward_type = QuestGlobals.RewardType.REWARD_OTHER
var quest_rarity =  QuestGlobals.Rarity.RARITY_COMMON
var is_completed = false
var description = "test"

var stat_being_tracked = QuestGlobals.StatTrack.STAT_DO_NOTHING
var signal_count_required = 1
var signal_count_current = 0
var signal_count_max_seen = 0


# TODO: Get UI to dynamically update

# TODO: implement stat tracking via pass through from quest manager

# TODO: may need to display more details about rewards

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass
