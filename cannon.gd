@tool
extends StaticBody2D

enum Direction {
  LEFT, RIGHT, UP, DOWN
}

@onready var BULLET: PackedScene = preload("res://bullet.tscn")
@onready var PROJECTILE_NODE: Node2D = $'/root/root/projectiles'
@onready var bullet_spawn = $graphic/bullet_spawn

@export var direction: Direction = Direction.RIGHT

var max_ticks_to_next_shot = 500
var ticks_to_next_shot = 100

func bullet_speed():
  return 100

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "trash"
  rotate_cannon()

func rotate_cannon():
  # Assumes cannon is pointing down. Which it definitely is. 
  var direction_vector = get_direction_vector()

  $graphic.rotation = direction_vector.angle() - PI / 2

func _process(delta):
  if Engine.is_editor_hint():
    rotate_cannon()
    return

  ticks_to_next_shot -= 1

  if ticks_to_next_shot <= 0:
    ticks_to_next_shot = max_ticks_to_next_shot

    shoot_bullet()

func shoot_bullet():
  var bullet: Node2D = BULLET.instantiate()
  var homing = false
  var speed = bullet_speed()
  var ricochets = false
  var pierces = false
  var damage = 1
  var effects = []
  
  bullet.configure(self, speed, damage, effects, homing, null, ricochets, pierces)
  PROJECTILE_NODE.add_child(bullet)

  var direction_vector = get_direction_vector()
  
  bullet.global_position = bullet_spawn.global_position
  bullet.global_rotation = direction_vector.angle()
  bullet.scale = Vector2(1, 1)

func get_direction_vector() -> Vector2:
  var direction_vector = Vector2(0, 0)

  if direction == Direction.LEFT:
    direction_vector = Vector2(-1, 0)
  elif direction == Direction.RIGHT:
    direction_vector = Vector2(1, 0)
  elif direction == Direction.UP:
    direction_vector = Vector2(0, -1)
  elif direction == Direction.DOWN:
    direction_vector = Vector2(0, 1)

  return direction_vector
