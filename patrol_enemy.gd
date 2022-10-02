extends CharacterBody2D

enum Direction {
  LEFT, RIGHT, UP, DOWN
}

@export var MOVEMENT_SPEED: float = 200.0
@export var initial_patrol_direction: Direction = Direction.RIGHT
var _current_direction: Vector2 = Vector2.ZERO

func _ready():
  _current_direction = get_direction_vector()

  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "common"

func _process(delta):
  velocity = MOVEMENT_SPEED * _current_direction * $base_enemy.get_speed_multiplier()

  var collided = move_and_slide()
  
  if collided:
    _current_direction *= Vector2(-1, -1)
  
  # hit the player
  for q in range(get_slide_collision_count()):
    var collision: KinematicCollision2D = get_slide_collision(q)
    var collider: Node2D = collision.get_collider()

    if collider.has_method("damage"):
      collider.damage(-1, - collider.position.direction_to(position))

func get_direction_vector() -> Vector2:
  var direction_vector = Vector2(0, 0)

  if initial_patrol_direction == Direction.LEFT:
    direction_vector = Vector2(-1, 0)
  elif initial_patrol_direction == Direction.RIGHT:
    direction_vector = Vector2(1, 0)
  elif initial_patrol_direction == Direction.UP:
    direction_vector = Vector2(0, -1)
  elif initial_patrol_direction == Direction.DOWN:
    direction_vector = Vector2(0, 1)

  return direction_vector
