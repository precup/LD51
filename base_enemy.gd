extends CharacterBody2D
class_name BaseEnemy

@export var _max_health: float = 5.0
const BURN_DAMAGE: float = 1.0

# Set this in the subclass.
# The superclass will take it and apply status modifiers before moving.
var desired_velocity: Vector2 = Vector2.ZERO

var _conditions: Array = [] # [condition: Modifiers.Effect, gun_id: int, condition_strength: float]
var _health: float = 5.0
var active_tween: Tween = null

# "common", "rare", "epic", "legendary"
# (This is unused currently.)
var _enemy_rarity = "common"

func _ready() -> void:
  $graphic.material.set_shader_parameter("solid_color", Color.TRANSPARENT)

func _process(__delta: float) -> void:
  $health_bar.update(_health, _max_health)

func _physics_process(delta: float) -> void:
  var time_left: float = 1.0
  var i: int = 0
  
  while i < len(_conditions):
    match _conditions[i][0]:
      Modifiers.Effect.STUN:
        if _conditions[i][2] > time_left:
          _conditions[i][2] -= time_left
          time_left = 0.0
        else:
          time_left -= _conditions[i][2]
          _conditions.remove_at(i)
          i -= 1
      Modifiers.Effect.FREEZE:
        if _conditions[i][2] > delta:
          _conditions[i][2] -= delta
          time_left *= 0.5
        else:
          time_left = time_left * lerp(0.5, 1.0, _conditions[i][2] / delta)
          _conditions.remove_at(i)
          i -= 1
      Modifiers.Effect.BURN:
        if _conditions[i][2] > delta:
          _conditions[i][2] -= delta
          damage(delta * BURN_DAMAGE)
        else:
          damage(_conditions[i][2] * BURN_DAMAGE)
          _conditions.remove_at(i)
          i -= 1
    i += 1
          
  velocity = desired_velocity * time_left

  move_and_slide()
  
  # hit the player
  for q in range(get_slide_collision_count()):
    var collision: KinematicCollision2D = get_slide_collision(q)
    var collider: Node2D = collision.get_collider()

    if collider.has_method("damage"):
      collider.damage(-1, - collider.position.direction_to(position))

func _hit_animation() -> void:
  if active_tween:
    active_tween.kill()

  $graphic.material.set_shader_parameter("solid_color", Color.WHITE)
  active_tween = create_tween()
  var r = active_tween.tween_property($graphic.material, "shader_parameter/solid_color", Color.TRANSPARENT, 0.2)
  
  r.set_trans(Tween.TRANS_QUAD)

func apply_condition(new_condition: Array) -> void:
  for condition in _conditions:
    if condition[0] == new_condition[0] and condition[1] == new_condition[1]:
      condition[2] += new_condition[2]
      return
  _conditions.append(new_condition)


# Dictionary is from Modifiers.Effect to its current strength
func get_status_effects() -> Dictionary: 
  var effects: Dictionary = {}
  for condition in _conditions:
    if condition[0] not in effects:
      effects[condition[0]] = 0.0
    effects[condition[0]] += effects[condition[2]]
  return effects


func damage(amount: float, weapon_id: int = -1) -> void:
  var i: int = 0
  while i < len(_conditions) and weapon_id != -1:
    match _conditions[i][0]:
      Modifiers.Effect.MARK:
        if _conditions[i][1] != weapon_id:
          amount += _conditions[i][2] * 2.0
          _conditions.remove_at(i)
          i -= 1
      Modifiers.Effect.STACK:
        continue
      Modifiers.Effect.UNSTACK:
        if _conditions[i][1] == weapon_id:
          amount += _conditions[i][2]
          _conditions.remove_at(i)
          i -= 1
    i += 1
      
  _health = max(0.0, _health - amount)

  if _health <= 0:
    destroy()
  else:
    _hit_animation()

func destroy(): 
  drop_random_item()

  queue_free()

var heart_pickup = preload("res://heart_pickup.tscn")

# TODO: Probably have an item drop table with rarities, etc.
func drop_random_item():
  # for now we just disregard the rarity entirely.

  var potential_pickups = [
    heart_pickup
  ]

  var pickup = potential_pickups[randi() % len(potential_pickups)]
  var pickup_instance = pickup.instantiate()

  pickup_instance.position = position
  get_parent().add_child(pickup_instance)
