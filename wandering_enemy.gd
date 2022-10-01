extends CharacterBody2D

@export var MOVEMENT_SPEED: float = 100.0
var _next_destination: Vector2 = Vector2.ZERO

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "common"

  _next_destination = position

func _choose_next_destination() -> void:
  var deltas = [
    Vector2.LEFT,
    Vector2.RIGHT,
    Vector2.UP,
    Vector2.DOWN
  ]

  var new_destination = position + 200 * deltas[randi() % deltas.size()]

  _next_destination = new_destination

  # TODO: Use this to determine if the new destination is valid
  # if get_node("/root/World").get_cellv(new_destination) == 0:
  #   next_destination = new_destination

func _process(delta):
  if _next_destination.distance_to(position) < 15:
    _choose_next_destination()

  velocity = MOVEMENT_SPEED * position.direction_to(_next_destination).normalized() * $base_enemy.get_speed_multiplier()

  move_and_slide()
  
  # hit the player
  for q in range(get_slide_collision_count()):
    var collision: KinematicCollision2D = get_slide_collision(q)
    var collider: Node2D = collision.get_collider()

    if collider.has_method("damage"):
      collider.damage(-1, - collider.position.direction_to(position))

  
