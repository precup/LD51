extends CharacterBody2D
class_name Enemy

var next_destination = Vector2.ZERO

func _ready():
  next_destination = position

func choose_next_destination():
  var deltas = [
    200 * Vector2.LEFT,
    200 * Vector2.RIGHT,
    200 * Vector2.UP,
    200 * Vector2.DOWN
  ]

  var new_destination = position + deltas[randi() % deltas.size()]

  next_destination = new_destination

  # TODO: Use this to determine if the new destination is valid
  # if get_node("/root/World").get_cellv(new_destination) == 0:
  #   next_destination = new_destination

func _process(_delta):
  if next_destination.distance_to(position) < 15:
    choose_next_destination()
  
  var direction = position.direction_to(next_destination).normalized()

  velocity = direction * 100

  move_and_slide()

func hit():
  print("HIT")
  queue_free()
