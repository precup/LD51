extends StaticBody2D

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "trash"  
  $base_enemy._stats_on_kill.append(QuestGlobals.StatTrack.STAT_BREAK_OBJECT)


var threshold = 0
func _physics_process(delta):
  if $base_enemy._health < 4 and threshold == 0:
    threshold = 1
    $graphic.texture = load("res://assets/pot_hit.png")
  if $base_enemy._health < 3 and threshold == 1:
    threshold = 2
    $graphic.texture = load("res://assets/pot_broken.png")
