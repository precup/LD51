extends CharacterBody2D

var next_destination = Vector2.ZERO
var health = 5
var max_health = 5

func _ready():
  $filler_image.material.set_shader_parameter("solid_color", Color.RED)
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
  $health_bar.update(health, max_health)
  
  if next_destination.distance_to(position) < 15:
    choose_next_destination()
  
  var direction = position.direction_to(next_destination).normalized()

  velocity = direction * 100

  move_and_slide()

func hit_animation():
  $filler_image.material.set_shader_parameter("solid_color", Color.WHITE)
  var tween = create_tween()
  tween.tween_property($filler_image.material, "shader_parameter/solid_color", Color.RED, 0.4)

func hit(damage):
  health -= damage

  if health <= 0:
    queue_free()
  else:
    hit_animation()
