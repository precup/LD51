extends CharacterBody2D

@export var MAX_HEALTH: float = 5.0
@export var MOVEMENT_SPEED: float = 100.0
const BURN_DAMAGE: float = 1.0
var _next_destination: Vector2 = Vector2.ZERO
var _health: float = 5.0
var _conditions: Array = [] # [condition: Modifiers.Effect, gun_id: int, condition_strength: float]


func _ready() -> void:
  $filler_image.material.set_shader_parameter("solid_color", Color.RED)
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


func _process(__delta: float) -> void:
  $health_bar.update(_health, MAX_HEALTH)


func _physics_process(delta: float) -> void:
  var time_left: float = delta
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
          
  
  if _next_destination.distance_to(position) < 15:
    _choose_next_destination()

  velocity = MOVEMENT_SPEED * position.direction_to(_next_destination).normalized() * time_left / delta
  move_and_slide()
  
  for q in range(get_slide_collision_count()):
    var collision: KinematicCollision2D = get_slide_collision(q)
    var collider: Node2D = collision.get_collider()

    if collider.has_method("damage"):
      collider.damage(-1, - collider.position.direction_to(position))

func _hit_animation() -> void:
  $filler_image.material.set_shader_parameter("solid_color", Color.WHITE)
  var tween = create_tween()
  tween.tween_property($filler_image.material, "shader_parameter/solid_color", Color.RED, 0.4)


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
    queue_free()
  else:
    _hit_animation()
