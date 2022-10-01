extends Camera2D

@export var POSITION_AVERAGE_FRACTION: float = 0.1

func _physics_process(__delta):
  var player = get_tree().get_first_node_in_group("player")
  if player:
    global_position = lerp(global_position, player.global_position, POSITION_AVERAGE_FRACTION)
  
