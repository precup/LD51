extends RigidBody2D

@onready var BULLET: PackedScene = preload("res://enemy_bullet.tscn")
@onready var PROJECTILE_NODE: Node2D = $'/root/root/projectiles'
@onready var bullet_spawn = $graphic/bullet_spawn

@export var bullet_speed: float = 500
@export var max_time_between_shots: float = 500

var max_ticks_to_choose_next_destination = 200
var ticks_to_next_shot = 0
var next_destination = Vector2.ZERO
var ticks_to_choose_next_destination = max_ticks_to_choose_next_destination
var _knockback = Vector2.ZERO

func _ready():
  next_destination = position
  
  $base_enemy._max_health = 30
  $base_enemy._health = 30
  $base_enemy._item_drop_type = "trash" #lol

func spread_fire():
  var player = $"/root/root/references".get_player()
  var direction = global_position.direction_to(player.global_position)

  for x in range(-50, 50 + 1, 10):
    shoot_bullet(direction.rotated(deg_to_rad(x)))
    
    for y in range(15):
      await get_tree().process_frame

func _process(delta):
  ticks_to_next_shot -= 1
  ticks_to_choose_next_destination -= 1

  if ticks_to_next_shot <= 0:
    ticks_to_next_shot = max_time_between_shots
    
    spread_fire()
  
  var velocity := Vector2.ZERO

  if position.distance_to(next_destination) >= 10:
    velocity = position.direction_to(next_destination).normalized() * 200 * delta
  
  velocity += _knockback * delta
  _knockback = lerp(_knockback, Vector2.ZERO, delta * 5)

  move_and_collide(velocity)
    
  if ticks_to_choose_next_destination <= 0:
    ticks_to_choose_next_destination = max_ticks_to_choose_next_destination
    next_destination = choose_next_destination() 

# choose a position that will be closest to 300 units away from the player
func choose_next_destination():
  var player = $"/root/root/references".get_player()
  var player_position = player.global_position

  if global_position.distance_to(player_position) > 1000:
    return position

  var destinations = [
    position + Vector2.LEFT * 100,
    position + Vector2.RIGHT * 100,
    position + Vector2.UP * 100,
    position + Vector2.DOWN * 100
  ]

  var best_destination = destinations[0]
  var best_difference = 1000000

  for destination in destinations:
    var distance = destination.distance_to(player_position)

    if abs(distance - 300) < best_difference:
      best_difference = abs(distance - 300)
      best_destination = destination
  
  return best_destination

func shoot_bullet(direction_vector: Vector2):
  var bullet: Node2D = BULLET.instantiate()
  var homing = false
  var ricochets = false
  var pierces = false
  var damage = 1
  var effects = []

  bullet.configure(self, bullet_speed, damage, effects, homing, null, ricochets, pierces, Color.RED)
  PROJECTILE_NODE.add_child(bullet)
  
  bullet.global_position = bullet_spawn.global_position
  bullet.get_node("sprite").global_rotation = direction_vector.angle()
  bullet.scale = Vector2(1, 1)

func knockback(bullet_vector: Vector2):
  _knockback = bullet_vector.normalized() * 500
