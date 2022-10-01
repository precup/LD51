extends CharacterBody2D

@export var PROJECTILE_NODE: Node2D
@export var SPEED: float = 400.0
@export var MAX_HEALTH: int = 8
const BULLET_SCENE: PackedScene = preload("res://bullet.tscn")
@onready var GUNS: Array = $guns.get_children()

var _last_direction: Vector2 = Vector2.LEFT
var _health: int = MAX_HEALTH


func _ready() -> void:
  for gun in GUNS:
    gun.PROJECTILE_NODE = PROJECTILE_NODE


func _physics_process(_delta):
  if Input.is_action_just_pressed("change_gun"):
    for gun in GUNS:
      gun.visible = not gun.visible
  
  var direction = Input.get_vector(
    "left", 
    "right",
    "up",
    "down"
  ) * SPEED

  velocity = direction

  if direction.length() > 0:
    _last_direction = direction.normalized()

  move_and_slide()


func health() -> int:
  return _health


func max_health() -> int:
  return MAX_HEALTH


func heal(amount: float) -> void:
  _health = min(MAX_HEALTH, _health + amount)


func damage(amount: float) -> void:
  _health = max(0, _health + amount)
  if _health == 0:
    print("u died")
  
