extends CharacterBody2D
class_name Player

var INVULN_LENGTH = 60
@export var PROJECTILE_NODE: Node2D
@export var SPEED: float = 400.0
@export var MAX_HEALTH: int = 8
const BULLET_SCENE: PackedScene = preload("res://bullet.tscn")

@onready var quest_manager = $"/root/root/quest_manager"

var _last_direction: Vector2 = Vector2.LEFT
var _health: int = MAX_HEALTH
var _knockback: Vector2 = Vector2.ZERO
var _invuln_frames = 0

func _ready() -> void:
  _health -= 2 # just for debugging
  
  for gun in $guns.get_children():
    gun.PROJECTILE_NODE = PROJECTILE_NODE

func get_active_gun():
  var guns: Array = $guns.get_children()
  for gun in guns:
    if gun.visible:
      return gun

  # Hopefully this never happens.
  return guns[0]

var boosted_speed = SPEED
const BOOSTED_SPEED_MULTIPLIER = 3
const BOOSTED_SPEED_DURATION = .25
const DASH_COOLDOWN = 2
var dash_cooldown_counter = 0

func _begin_dash():
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_DASH) 
  dash_cooldown_counter = DASH_COOLDOWN
  var tween = get_tree().create_tween()
  tween.tween_property(self, "boosted_speed", BOOSTED_SPEED_MULTIPLIER*SPEED, BOOSTED_SPEED_DURATION/3.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)       
  tween.tween_interval(BOOSTED_SPEED_DURATION/3.0)        
  tween.tween_property(self, "boosted_speed", SPEED,  BOOSTED_SPEED_DURATION/3.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)      
  tween.tween_interval(DASH_COOLDOWN - BOOSTED_SPEED_DURATION)    
  tween.tween_property(self, "modulate", Color(.6,.6,1,1), .12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)    
  tween.tween_property(self, "modulate", Color(1,1,1,1), .06).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)  

func _physics_process(_delta):
  dash_cooldown_counter-=_delta
  if Input.is_action_just_pressed("dash") && dash_cooldown_counter <= 0:
    # TODO: put a CD on this, have UI show CD
    _begin_dash()
    
  if Input.is_action_just_pressed("change_gun"):
    for gun in $guns.get_children():
      gun.visible = not gun.visible
  
  var direction = Input.get_vector(
    "left", 
    "right",
    "up",
    "down"
  ) * boosted_speed
  
  if _knockback != Vector2.ZERO:
    velocity = _knockback
  else:
    velocity = direction
  
  attentuate_knockback()
  
  if _invuln_frames > 0:
    _invuln_frames -= 1

  if direction.length() > 0:
    _last_direction = direction.normalized()

  move_and_slide()
  
  if get_slide_collision_count() > 0:
    handle_collisions()
    quest_manager.quest_start_timer(QuestGlobals.StatTrack.STAT_CONTINUOUSLY_TOUCH_WALL) 
  elif direction.length() > 0:    
    quest_manager.quest_reset_timer(QuestGlobals.StatTrack.STAT_CONTINUOUSLY_TOUCH_WALL) 

func attentuate_knockback():
  if _knockback == Vector2.ZERO:
    return
    
  _knockback *= 0.80
  
  if _knockback.length() <= 200:
    _knockback = Vector2.ZERO

func handle_collisions():
  for i in get_slide_collision_count():
    var collision = get_slide_collision(i)
    
    print(collision)

func health() -> int:
  return _health


func max_health() -> int:
  return MAX_HEALTH


func heal(amount: float) -> void:
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_HEAL, abs(amount))
  _health = min(MAX_HEALTH, _health + amount)

func play_flicker_animation():
  for x in range(60):
    if floor(x / 10) % 2 == 0:
      visible = false
    else:
      visible = true
    
    await get_tree().process_frame
    
  visible = true

func damage(amount: float, knockback: Vector2 = Vector2.ZERO) -> void:
  if _invuln_frames > 0:
    return
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_GET_HIT)  
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_LOSE_HEARTS, abs(amount))
  _health = max(0, _health + amount)
  _invuln_frames = INVULN_LENGTH
  
  play_flicker_animation()

  if knockback != Vector2.ZERO:
    _knockback = knockback.normalized() * 1000
    # move_and_slide()
  
  if _health == 0:
    print("u died")
    return

func pickup(item: String) -> void:
  quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_PICKUP_ITEM)
  if item == "heart":
    heal(1)
