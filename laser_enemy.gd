extends CharacterBody2D

enum Direction {
  LEFT, RIGHT, UP, DOWN
}

@export var MOVEMENT_SPEED: float = 200.0
@export var facing_direction: Direction = Direction.RIGHT

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "common"

func get_facing_direction_vector() -> Vector2:
  match facing_direction:
    Direction.LEFT:
      return Vector2(-1, 0)
    Direction.RIGHT:
      return Vector2(1, 0)
    Direction.UP:
      return Vector2(0, -1)
    Direction.DOWN:
      return Vector2(0, 1)
  return Vector2.LEFT
