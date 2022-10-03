extends CharacterBody2D

var _gun = null
var _speed: float = 0.
var _damage: float = 0.
var _homing: float = 0.
var _richocets: int = 0
var _pierces: int = 0
var _effects: Array = []
var _target: Node2D = null
var _has_returned: bool = false

@onready var quest_manager = $"/root/root/quest_manager"

func configure(gun, speed: float, damage: float, effects: Array, homing: float, target: Node2D, richochets: int, pierces: int):
  _gun = gun
  _speed = speed
  _damage = damage
  _effects = effects
  _target = target
  _homing = homing
  _richocets = richochets
  _pierces = pierces

  # prevent collisoin w self
  
  add_collision_exception_with(gun)


func _physics_process(delta):
  var direction: Vector2 = transform.x
  var collision: KinematicCollision2D = move_and_collide(direction * _speed * delta)
  
  if collision:
    var collider: Object = collision.get_collider().get_node('base_enemy')
    var enemy_hit: bool = false
    var destructible_hit = false
      
    # never collide against self
    if collider != null and collider.get_parent() == _gun:
      return

    for enemy in get_tree().get_nodes_in_group("enemies"):
      if enemy.get_node('base_enemy') == collider:
        enemy_hit = true
        break
    
    for destructible in get_tree().get_nodes_in_group("destructible"):
      if destructible.get_node('base_enemy') == collider:
        destructible_hit = true
    
    if enemy_hit:
      var react_damage: float = 1.0
      quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_HIT_ENEMY)
      
      for effect in _effects:
        match effect[0]:
          Modifiers.Effect.REACT:
            react_damage += 0.25 * len(collider.get_status_effects())
          Modifiers.Effect.LEECH:
            var player = get_tree().get_first_node_in_group("player")
            if player:
              player.heal(effect[2])
          Modifiers.Effect.RETURN:
            if not _has_returned:
              _has_returned = true
              _gun.return_bullet()
      collider.damage(_damage * react_damage, -1, direction)
      for effect in _effects:
        quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_APPLY_EFFECT)
        match effect[0]:
          Modifiers.Effect.FREEZE:
            collider.apply_condition(effect)
          Modifiers.Effect.BURN:
            collider.apply_condition(effect)
          Modifiers.Effect.STUN:
            collider.apply_condition(effect)
          Modifiers.Effect.MARK:
            collider.apply_condition(effect)
          Modifiers.Effect.INTOXICATE:
            collider.apply_condition(effect)
          Modifiers.Effect.STACK:
            collider.apply_condition(effect)
          Modifiers.Effect.UNSTACK:
            collider.apply_condition(effect)
      if _pierces > 0:
        add_collision_exception_with(collider)
        _pierces -= 1
      else:
        _destroy()
    elif destructible_hit:
      var destructible: Node2D = collision.get_collider().get_node("base_enemy")
      
      destructible.damage(_damage)
      _destroy("pot")
    else: # Wall hit
      if _richocets > 0:
        _richocets -= 1
        _make_hitspark("wall")
        look_at(global_position + direction.bounce(collision.get_normal()))
      else:
        _destroy("wall")

@onready var hitsprite = preload("res://hitsprite.tscn")
@onready var hitsprite_wall = preload("res://hitsprite_wall.tscn")

func _make_hitspark(target = "enemy") -> void:
  var instance: Node2D
  
  if target == "wall":
    instance = hitsprite_wall.instantiate()
    $"/root/root/sfx/wall_hit".play()
  elif target == "pot":
    instance = hitsprite_wall.instantiate()
    $"/root/root/sfx/pot_hit".play()
  else:
    instance = hitsprite.instantiate()
    $"/root/root/sfx/enemy_hit".play()
    
  $"/root/root".add_child(instance)
  instance.global_position = global_position

func _destroy(target = "enemy") -> void:
  _make_hitspark(target)

  queue_free()
    
