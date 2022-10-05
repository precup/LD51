extends Camera2D

@export var POSITION_AVERAGE_FRACTION: float = 0.1
@export var CAMERA_OFFSET: Vector2 = Vector2(37, 0)

func _ready():
  var player = get_tree().get_first_node_in_group("player")
  global_position = player.get_node("gun_rotation_container").global_position + CAMERA_OFFSET


func _physics_process(__delta):
  var player = get_tree().get_first_node_in_group("player")
  if player:
    global_position = lerp(global_position, player.get_node("gun_rotation_container").global_position, POSITION_AVERAGE_FRACTION) + CAMERA_OFFSET
  
