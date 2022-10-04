extends Node2D

@onready var BULLET: PackedScene = preload("res://bullet.tscn")
@onready var BULLET_SPAWN: Marker2D = $sprite/top/bullet_spawn
@onready var GUN_ID: int = randi()

@export var COLOR: Color = Color.WHITE
@export var RARITY: QuestGlobals.Rarity = QuestGlobals.Rarity.RARITY_COMMON
@export var BASE_RELOAD_TIME: float = 1.0
@export var BASE_FIRE_COOLDOWN: float = 0.3
@export var BASE_MAGAZINE_SIZE: int = 10
@export var BASE_BULLET_SPEED: float = 1200.
@export var BASE_BULLET_DAMAGE: float = 1
@export var BASE_BULLET_HOMING: float = 0.
@export var BASE_BULLET_PIERCES: int = 0
@export var BASE_BULLET_RICOCHETS: int = 0
@export var BASE_SCATTER_DAMAGE_LOSS: float = 0.6
@export var BASE_STUNNING_PROC_CHANCE: float = 0.1
@export var BASE_STUNNING_DURATION: float = 1.0
@export var BASE_FREEZE_DURATION: float = 1.0
@export var BASE_BURN_DURATION: float = 1.0
@export var BASE_INTOXICATION_DURATION: float = 1.0
@export var BASE_VAMPIRISM_PROC_CHANCE: float = 0.1
@export var BASE_VAMPIRISM_HEAL: int = 1
@export var BASE_BLAZE_OF_GLORY_THRESHOLD: float = 0.3
@export var BASE_BLAZE_OF_GLORY_MULTIPLIER: float = 3.0
@export var BASE_GROW: float = 2.0
@export var BASE_IMPACT: float = 30.0
@export var BASE_FLEET: float = 300.0
@export var BASE_HOMING: float = 1.3

@export var MAX_MODIFIERS: int = 5
@export var UPGRADES: Array[Modifiers.Gun] = []

@export var PROJECTILE_NODE: Node2D

@onready var quest_manager = $"/root/root/quest_manager"

var bonus_speed = 0

var rainbow_colors = [
  Color("9400D3"),
  Color("9400D3"),
  Color("4B0082"),
  Color("4B0082"),
  Color("0000FF"),
  Color("0000FF"),
  Color("00FF00"),
  Color("00FF00"),
  Color("FFFF00"),
  Color("FFFF00"),
  Color("FF7F00"),
  Color("FF7F00"),
  Color("FF0000"),
  Color("FF0000"),
]
var rainbow_counter = 0

var _rounds_left: int = 0
var _fire_cooldown_left: float = 0
var _reload_left: float = 0

func _ready() -> void:
  _rounds_left = magazine_size()
  $sprite.modulate = COLOR
  
  $explode.visible = false

func get_rounds_left() -> int:
  return _rounds_left

var upgrade_count = 0
func _physics_process(delta) -> void:
  if not visible:
    return
  
  if upgrade_count != len(UPGRADES):
    upgrade_count = len(UPGRADES)
    bonus_speed = 0
    for upgrade in UPGRADES:
      if upgrade == Modifiers.Gun.FLEET:
        bonus_speed += BASE_FLEET
  
  $sprite.scale.y = 1 if abs(global_rotation) > PI / 2 else -1
  
  if Input.is_action_just_pressed("reload"):
    start_reload()
  elif _reload_left > 0:
    _reload_left -= delta
    if _reload_left <= 0:
      reload()
  elif _fire_cooldown_left > 0:
    _fire_cooldown_left -= delta
  elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
    if _rounds_left > 0:
      fire()
    else:
      start_reload()
  

func fire(free: bool = false, start = null, target = Vector2.ZERO, chain_value = 0, ignore_box = null) -> void:
  var num_shots: int = 1
  var arc_size: float = 0.
  var damage: float = bullet_damage()
  var effects: Array = []
  var scale: float = 1.0
  var color = COLOR
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_FIRE_GUN)
  
  var should_eat = false
  
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.BULLET_EATER:
        should_eat = true
      Modifiers.Gun.RAINBOW:
        color = rainbow_colors[rainbow_counter]
        rainbow_counter = (rainbow_counter + 1) % len(rainbow_colors)
      Modifiers.Gun.SCATTERSHOT:
        arc_size = max(arc_size, PI / 6)
        num_shots += 3
      Modifiers.Gun.RADIAL:
        arc_size = PI
        num_shots += 3
      Modifiers.Gun.STUNNING:
        if randf() < BASE_STUNNING_PROC_CHANCE:
          effects.append([Modifiers.Effect.STUN, -1, BASE_STUNNING_DURATION])
      Modifiers.Gun.MARKING:
        effects.append([Modifiers.Effect.MARK, GUN_ID, damage])
        damage = 0.0
      Modifiers.Gun.FREEZING:
        effects.append([Modifiers.Effect.FREEZE, -1, BASE_FREEZE_DURATION])
      Modifiers.Gun.FRONT_LOADED:
        effects.append([Modifiers.Effect.UNSTACK, GUN_ID, -1])
      Modifiers.Gun.STACKING:
        effects.append([Modifiers.Effect.STACK, GUN_ID, 1])
      Modifiers.Gun.REACTIVE:
        effects.append([Modifiers.Effect.REACT, -1, -1])
      Modifiers.Gun.HOT_SHOT:
        effects.append([Modifiers.Effect.BURN, -1, BASE_BURN_DURATION])
      Modifiers.Gun.GROWING:
        var found = false
        for i in range(len(effects)):
          if effects[i][0] == Modifiers.Effect.GROW:
            effects[i][2] += BASE_GROW
            found = true
        if not found:
          effects.append([Modifiers.Effect.GROW, -1, BASE_GROW])
      Modifiers.Gun.HOMING:
        var found = false
        for i in range(len(effects)):
          if effects[i][0] == Modifiers.Effect.HOMING:
            effects[i][2] += BASE_HOMING
            found = true
        if not found:
          effects.append([Modifiers.Effect.HOMING, -1, BASE_HOMING])
      Modifiers.Gun.RETURNING:
        effects.append([Modifiers.Effect.RETURN, -1, -1])
      Modifiers.Gun.EXPLOSIVE:
        var found = false
        for i in range(len(effects)):
          if effects[i][0] == Modifiers.Effect.EXPLODE:
            effects[i][2] += 300
            found = true
        if not found:
          effects.append([Modifiers.Effect.EXPLODE, -1, 300])
      Modifiers.Gun.BIG_SHOT:
        scale *= 2.0
      Modifiers.Gun.IMPACT:
        effects.append([Modifiers.Effect.IMPACT, -1, BASE_IMPACT])
      Modifiers.Gun.TRICK_SHOT:
        effects.append([Modifiers.Effect.TRICK_SHOT, -1, -1])
      Modifiers.Gun.CHAIN:
        var found = false
        for i in range(len(effects)):
          if effects[i][0] == Modifiers.Effect.CHAIN:
            effects[i][2] += 1
            found = true
        if not found:
          effects.append([Modifiers.Effect.CHAIN, -1, 1])
      Modifiers.Gun.INTOXICATING:
        effects.append([Modifiers.Effect.INTOXICATE, -1, BASE_INTOXICATION_DURATION])
      Modifiers.Gun.BLAZE_OF_GLORY:
        var player = get_tree().get_first_node_in_group("player")
        if player:
          var health_fraction = player.health() / float(player.max_health())
          if health_fraction < BASE_BLAZE_OF_GLORY_THRESHOLD:
            damage *= BASE_BLAZE_OF_GLORY_MULTIPLIER
      Modifiers.Gun.VAMPIRIC:
        if randf() < BASE_VAMPIRISM_PROC_CHANCE:
          effects.append([Modifiers.Effect.LEECH, -1, BASE_VAMPIRISM_HEAL])
  
  var rem = -1
  for i in range(len(effects)):
    if effects[i][0] == Modifiers.Effect.CHAIN and effects[i][2] == 1 and free:
      rem = i
      break
  if rem >= 0:
    effects.remove_at(rem)
  
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_FIRE_SHOT, num_shots)
  for i in range(num_shots):
    var arc_angle: float = lerp(-arc_size, arc_size, float(i) / max(1, num_shots - 1))
    if arc_size >= PI:
      arc_angle = lerp(0.0, TAU, float(i) / num_shots)
    var bullet: Node2D = BULLET.instantiate()
    bullet.configure(self, bullet_speed(), damage, effects, bullet_homing(), null, bullet_ricochets(), bullet_pierces(), color)
    PROJECTILE_NODE.add_child(bullet)
    bullet.global_position = BULLET_SPAWN.global_position if not free else start
    if target != Vector2.ZERO:
      bullet.get_node("sprite").global_rotation = bullet.get_angle_to(target) + arc_angle
    else:
      bullet.get_node("sprite").global_rotation = bullet.get_angle_to(get_global_mouse_position()) + arc_angle
    if ignore_box != null:
      bullet.add_collision_exception_with(ignore_box.get_parent())
    bullet.scale = Vector2(scale, scale)
    bullet.set_collision_mask_value(4, should_eat)
    _fire_cooldown_left = fire_cooldown()
  
  if not free:
    var player = $"/root/root/references".get_player()
    player.gun_was_fired()
  
  if not Modifiers.Gun.BOTTOMLESS_MAGAZINE in UPGRADES and not free:
    _rounds_left -= 1


  var expl: AnimatedSprite2D = $explode
  $explode.frame = 0
  $explode.visible = true
  $explode.play()
  
  await $explode.animation_finished
  
  $explode.visible = false
  
  

func start_reload() -> void:
  _reload_left = reload_time()
  if _reload_left <= 0:
    _rounds_left = magazine_size()
    reload()


func reload() -> void:
  $"/root/root/sfx/reload".play()
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_RELOAD)
  _rounds_left = magazine_size()

func reload_time() -> float:
  var time: float = BASE_RELOAD_TIME
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.QUICK_RELOAD:
        time = time * 0.5
      Modifiers.Gun.POWERFUL:
        time = time * 1.5
  return time


func magazine_size(include_one_hit_wonder: bool = true) -> int:
  var mag_size: int = BASE_MAGAZINE_SIZE
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.LARGE_MAGAZINE:
        mag_size = int(mag_size * 2.0)
      Modifiers.Gun.ONE_HIT_WONDER:
        return 1
      Modifiers.Gun.RAINBOW:
        mag_size = int(mag_size * 1.5)
  return mag_size


func fire_cooldown() -> float:
  var cooldown: float = BASE_FIRE_COOLDOWN
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.RAPID_FIRE:
        cooldown = cooldown * 0.5
      Modifiers.Gun.POWERFUL:
        cooldown = cooldown * 1.5
      Modifiers.Gun.RAINBOW:
        cooldown = cooldown * 0.33
  return cooldown


func bullet_speed() -> float:
  var speed: float = BASE_BULLET_SPEED
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.SPEEDY:
        speed = speed * 2.0
  return speed


func bullet_damage() -> float:
  var damage: float = BASE_BULLET_DAMAGE
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.ONE_HIT_WONDER:
        damage = damage * max(1.0, magazine_size(false) / 2.0)
      Modifiers.Gun.POWERFUL:
        damage = damage * 2.0
      Modifiers.Gun.SCATTERSHOT:
        damage = damage * BASE_SCATTER_DAMAGE_LOSS
      Modifiers.Gun.FRONT_LOADED:
        damage = damage * 2.0
      Modifiers.Gun.RAINBOW:
        damage = damage * 0.75
  return damage


func bullet_homing() -> float:
  var homing: float = BASE_BULLET_HOMING
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.HOMING:
        homing += 1.0
  return homing


func bullet_ricochets() -> int:
  var ricochets: int = BASE_BULLET_RICOCHETS
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.RICOCHET:
        ricochets += 1
  return ricochets


func bullet_pierces() -> int:
  var pierces: int = BASE_BULLET_PIERCES
  for upgrade in UPGRADES:
    match upgrade:
      Modifiers.Gun.PIERCING:
        pierces += 1
  return pierces


func return_bullet() -> void:
  if _rounds_left < magazine_size():
    _rounds_left += 1


func get_reload_progress() -> float:
  if _reload_left <= 0:
    return -1.0
  return _reload_left / reload_time()
  
