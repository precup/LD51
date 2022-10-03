extends Node2D

@onready var graphic = $"../graphic"
@onready var health_bar = $"../health_bar"

@export var _max_health: float = 5.0
const BURN_DAMAGE: float = 1.0

@onready var quest_manager = $"/root/root/quest_manager"

# Set this in the subclass.
# The superclass will take it and apply status modifiers before moving.
var desired_velocity: Vector2 = Vector2.ZERO

var _conditions: Array = [] # [condition: Modifiers.Effect, gun_id: int, condition_strength: float]
var _health: float = 5.0
var active_tween: Tween = null
var _speed_multiplier = 1.0

var WAKE_UP_DISTANCE = 750
var SLEEP_DISTANCE = 1500
var _active = false

# "trash", "common", "rare", "epic", "legendary"
# (This is unused currently.)
var _item_drop_type = "common"
var _stats_on_kill = [QuestGlobals.StatTrack.STAT_KILL_ENEMY]

func _ready() -> void:
  graphic.material.set_shader_parameter("solid_color", Color.TRANSPARENT)

func _physics_process(delta: float) -> void:
  var player = $"/root/root/references".get_player()
  
  # Only wake up if player is nearby so we arent doing tons of stuff when the player is really far away!
  # note: cant set set_process in _ready b/c our _ready happens before theirs and so godot just ignores the value... :thonk:
  if not _active:
    if player.global_position.distance_to(global_position) < WAKE_UP_DISTANCE:
      _active = true
      get_parent().set_process(true)
    else:
      get_parent().set_process(false)
      return

  if _active:
    if player.global_position.distance_to(global_position) >= SLEEP_DISTANCE:
      _active = false
      get_parent().set_process(false)
      return
    else:
      get_parent().set_process(true)

  var speed_multiplier: float = 1.0
  var i: int = 0
  
  while i < len(_conditions):
    match _conditions[i][0]:
      Modifiers.Effect.STUN:
        if _conditions[i][2] > speed_multiplier:
          _conditions[i][2] -= speed_multiplier
          speed_multiplier = 0.0
        else:
          speed_multiplier -= _conditions[i][2]
          _conditions.remove_at(i)
          i -= 1
      Modifiers.Effect.FREEZE:
        if _conditions[i][2] > delta:
          _conditions[i][2] -= delta
          speed_multiplier *= 0.5
        else:
          speed_multiplier = speed_multiplier * lerp(0.5, 1.0, _conditions[i][2] / delta)
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

  _speed_multiplier = speed_multiplier

func get_speed_multiplier() -> float:
  return _speed_multiplier

func _hit_animation() -> void:
  # flash white
  
  if active_tween:
    active_tween.kill()

  graphic.material.set_shader_parameter("solid_color", Color.WHITE)
  active_tween = create_tween()
  var r = active_tween.tween_property(graphic.material, "shader_parameter/solid_color", Color.TRANSPARENT, 0.1)
  
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

func knockback(bullet_vector: Vector2):
  if get_parent().has_method("knockback"):
    get_parent().knockback(bullet_vector)

func damage(amount: float, weapon_id: int = -1, bullet_vector: Vector2 = Vector2.ZERO) -> void:
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
    for stat in _stats_on_kill:
      quest_manager.quest_count_progress(stat)
      
    destroy()
  else:
    if bullet_vector != Vector2.ZERO:
      knockback(bullet_vector)
    _hit_animation()

func destroy(): 
  drop_random_item()

  get_parent().queue_free()

var heart_pickup = preload("res://heart_pickup.tscn")

# TODO: Probably have an item drop table with rarities, etc.
func drop_random_item():
  # for now we just disregard the rarity entirely, but eventually we should use
  # enemy_rarity rather than tossing it in the garbage as we do
  #if randi() % 10 < 6:
  #  return

  var potential_pickups = [
    heart_pickup
  ]

  var pickup = potential_pickups[randi() % len(potential_pickups)]
  var pickup_instance = pickup.instantiate()

  pickup_instance.global_position = global_position + Vector2(50, 50)
  $"/root/root/pickups".add_child(pickup_instance)
  
  # get_parent().move_child(pickup_instance, 0)
  
  print(pickup_instance)
