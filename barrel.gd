extends StaticBody2D

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "trash"  
  $base_enemy._stats_on_kill.append(QuestGlobals.StatTrack.STAT_BREAK_OBJECT)

func _process(delta):
  pass
