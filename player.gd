extends CharacterBody2D

var speed = 400
var bullet_scene = preload("res://bullet.tscn")
var last_direction = Vector2.LEFT

func _process(_delta):
  var direction = Input.get_vector(
    "ui_left", 
    "ui_right",
    "ui_up",
    "ui_down"
  ) * 300

  velocity = direction

  if direction.length() > 0:
    last_direction = direction.normalized()

  move_and_slide()
  check_for_shoot()

func check_for_shoot():
  if Input.is_action_just_pressed("shoot"):
    var bullet = bullet_scene.instantiate()

    bullet.position = position
    bullet.rotation = rotation
    get_parent().add_child(bullet)

    bullet.initialize(last_direction, self)
