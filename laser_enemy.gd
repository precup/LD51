extends CharacterBody2D

enum Direction {
  LEFT, RIGHT, UP, DOWN
}

@export var MOVEMENT_SPEED: float = 200.0
@export var initial_patrol_direction: Direction = Direction.RIGHT

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "common"
#
#func _process(delta):
#  print("Hello world")
