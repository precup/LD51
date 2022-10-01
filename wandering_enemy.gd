extends BaseEnemy

@export var MOVEMENT_SPEED: float = 100.0
var _next_destination: Vector2 = Vector2.ZERO

func _ready():
  super._ready()

  _next_destination = position
  MAX_HEALTH = 5.0
  _health = 5.0

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
  super._process(delta)

  if _next_destination.distance_to(position) < 15:
    _choose_next_destination()

  # read and used by superclass.
  desired_velocity = MOVEMENT_SPEED * position.direction_to(_next_destination).normalized()
  
