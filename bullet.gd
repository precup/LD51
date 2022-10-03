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
var _growth: float = 0

@onready var quest_manager = $"/root/root/quest_manager"

func configure(gun, speed: float, damage: float, effects: Array, homing: float, target: Node2D, richochets: int, pierces: int, color: Color):
  _gun = gun
  _speed = speed
  _damage = damage
  _effects = effects
  _target = target
  _homing = 0
  _richocets = richochets
  _pierces = pierces
  
  for i in range(len(effects)):
    if effects[i][0] == Modifiers.Effect.GROW:
      _growth += effects[i][2]
    if effects[i][0] == Modifiers.Effect.HOMING:
      _homing += effects[i][2]
  
  $sprite.modulate = color

  # prevent collisoin w self
  
  add_collision_exception_with(gun)

var homing_step = 0.2
var homing_left = 0
var homing_target = null
func _physics_process(delta):
  if _growth > 0:
    scale.x += (delta * _speed / 1200) * _growth
    scale.y += (delta * _speed / 1200) * _growth
  
  homing_left -= delta
  if _homing > 0 and (homing_left < 0 or homing_target == null):
    homing_left -= homing_step
    homing_target = get_closest_target(null)
  
  if _homing > 0:
    var home_amount = _homing * delta * _speed / 1200
    var curr_rot = global_rotation
    var target_angle = $sprite.global_position.direction_to(homing_target)
    var curr_angle = $sprite.global_transform.x
    var angle_between = abs(curr_angle.angle_to(target_angle))
    var home_dir = curr_angle.slerp(target_angle, min(1.0, home_amount / angle_between))
    $sprite.look_at($sprite.global_position + home_dir)
  
  var direction: Vector2 = $sprite.global_transform.x
  var collision: KinematicCollision2D = move_and_collide(direction * _speed * delta)
  var player = $"/root/root/references".get_player()
  
  if collision:
    if collision.get_collider().has_method("_make_hitspark"):
      collision.get_collider().queue_free()
      return
    
    if collision.get_collider() == player:
      if player.dashing:
        add_collision_exception_with(player)
        return
      player.damage(-_damage, direction)
    
    var stacks = false
    var stacknum = -1
    for effect in _effects:
      if effect[0] == Modifiers.Effect.STACK:
        stacks = true
        stacknum = effect[1]
        break
    
    if stacks:
      for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy != collision.get_collider():
          var i = 0
          while i < len(enemy.get_node('base_enemy')._conditions):
            if enemy.get_node('base_enemy')._conditions[i][0] == Modifiers.Effect.STACK and enemy.get_node('base_enemy')._conditions[i][1] == stacknum:
              enemy.get_node('base_enemy')._conditions.remove_at(i)
              i -= 1
            i += 1
    
    var collider: Object = collision.get_collider().get_node('base_enemy')
    var enemy_hit: bool = false
    var destructible_hit = false
      
    # never collide against self
    if collider != null and collider.get_parent() == _gun:
      return

    var explode_radius = 0
    for effect in _effects:
      if effect[0] == Modifiers.Effect.EXPLODE:
        explode_radius += effect[2]
    
    var enemies_hit = []
    for enemy in get_tree().get_nodes_in_group("enemies"):
      if enemy.get_node('base_enemy') == collider:
        enemies_hit.append(enemy.get_node('base_enemy'))
        enemy_hit = true
        if explode_radius == 0:
          break
      elif explode_radius > 0 and explode_radius > global_position.distance_to(enemy.get_node('base_enemy').global_position):
        enemies_hit.append(enemy.get_node('base_enemy'))
    
    var destructibles_hit = []
    for destructible in get_tree().get_nodes_in_group("destructible"):
      if destructible.get_node('base_enemy') == collider:
        destructibles_hit.append(destructible.get_node('base_enemy'))
        destructible_hit = true
      elif explode_radius > 0 and explode_radius > global_position.distance_to(destructible.get_node('base_enemy').global_position):
        destructibles_hit.append(destructible.get_node('base_enemy'))
    
    var chained = false
    for enemy in enemies_hit:
      var react_damage: float = 1.0
      quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_HIT_ENEMY)
      
      for effect in _effects:
        match effect[0]:
          Modifiers.Effect.REACT:
            react_damage += 0.25 * len(enemy.get_status_effects())
          Modifiers.Effect.LEECH:
            if player:
              player.heal(effect[2])
          Modifiers.Effect.RETURN:
            if not _has_returned:
              _has_returned = true
              _gun.return_bullet()
          Modifiers.Effect.TRICK_SHOT:
            if player.global_position.direction_to(get_global_mouse_position()).dot(player.global_position.direction_to(global_position)) < 0:
              _damage *= 3.0
              
      enemy.damage(_damage * react_damage, -1, direction)
      
      for effect in _effects:
        quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_APPLY_EFFECT)
        match effect[0]:
          Modifiers.Effect.FREEZE:
            enemy.apply_condition(effect)
          Modifiers.Effect.BURN:
            enemy.apply_condition(effect)
          Modifiers.Effect.STUN:
            enemy.apply_condition(effect)
          Modifiers.Effect.MARK:
            enemy.apply_condition(effect)
          Modifiers.Effect.INTOXICATE:
            enemy.apply_condition(effect)
          Modifiers.Effect.STACK:
            enemy.apply_condition(effect)
          Modifiers.Effect.UNSTACK:
            enemy.apply_condition(effect)
          Modifiers.Effect.CHAIN:
            if not chained:
              chained = true
              chain(collider, player)
            
    if enemy_hit:
      if _pierces > 0:
        for enemy in enemies_hit:
          add_collision_exception_with(enemy)
        _pierces -= 1
      else:
        _destroy()
    for destructible in destructibles_hit:
      destructible.damage(_damage)
    if destructible_hit:
      _destroy("pot")
      if not chained:
        for effect in _effects:
          if effect[0] == Modifiers.Effect.CHAIN:
            chain(collider, player)
      
    if not (destructible_hit or enemy_hit): # Wall hit
      if _richocets > 0:
        _richocets -= 1
        _make_hitspark("wall", true)
        look_at(global_position + direction.bounce(collision.get_normal()))
      else:
        _destroy("wall")
    
    if explode_radius > 0:
      if player and player.global_position.distance_to(global_position) < explode_radius:
        player.damage(-_damage)


func get_closest_target(avoid):
    var closest = null
    var dist = 0
    for enemy2 in get_tree().get_nodes_in_group("enemies"):
      if enemy2.get_node('base_enemy') != avoid:
        var d = enemy2.get_node('base_enemy').global_position.distance_to(global_position)
        if closest == null or d < dist:
          dist = d
          closest = enemy2.get_node('base_enemy').global_position
    for enemy2 in get_tree().get_nodes_in_group("destructible"):
      if enemy2.get_node('base_enemy') != avoid and not enemy2.has_method("_on_spike_trap_body_entered"):
        var d = enemy2.get_node('base_enemy').global_position.distance_to(global_position)
        if closest == null or d < dist:
          dist = d
          closest = enemy2.get_node('base_enemy').global_position
    return closest


func chain(curr, player):
  var closest = get_closest_target(curr)
  player.get_active_gun().fire(true, global_position, closest if closest != null else (global_position + transform.x), curr)


@onready var hitsprite = preload("res://hitsprite.tscn")
@onready var hitsprite_wall = preload("res://hitsprite_wall.tscn")

func _make_hitspark(target = "enemy", is_ricochet = false) -> void:
  var instance: Node2D
  
  if target == "wall":
    instance = hitsprite_wall.instantiate()
    if is_ricochet:
      $"/root/root/sfx/ricochet_3".play()    
    else:
      $"/root/root/sfx/wall_hit".play()
  elif target == "pot":
    instance = hitsprite_wall.instantiate()
    $"/root/root/sfx/pot_hit".play()
  else:
    instance = hitsprite.instantiate()
    $"/root/root/sfx/enemy_hit".play()
    
  $"/root/root".add_child(instance)
  
  instance.global_position = global_position
  
  for effect in _effects:
    if effect[0] == Modifiers.Effect.EXPLODE:
      instance.scale = Vector2(effect[2] / 64, effect[2] / 64)

func _destroy(target = "enemy") -> void:
  _make_hitspark(target)

  queue_free()
    
