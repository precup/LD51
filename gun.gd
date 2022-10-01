extends Node2D

@onready var BULLET: PackedScene = preload("res://bullet.tscn")
@onready var BULLET_SPAWN: Marker2D = $sprite/bullet_spawn
@onready var GUN_ID: int = randi()

@export var BASE_RELOAD_TIME: float = 1.0
@export var BASE_FIRE_COOLDOWN: float = 0.1
@export var BASE_MAGAZINE_SIZE: int = 10
@export var BASE_BULLET_SPEED: float = 500.
@export var BASE_BULLET_DAMAGE: float = 1.

@export var MAX_MODIFIERS: int = 5
@export var UPGRADES: Array[Modifiers.Gun] = []

@export var PROJECTILE_NODE: Node2D

var _rounds_left: int = 0
var _fire_cooldown_left: float = 0
var _reload_left: float = 0

func _ready() -> void:
    assert(PROJECTILE_NODE)
    _rounds_left = magazine_size()


func _physics_process(delta) -> void:
    if not visible:
        return
    
    rotation += get_angle_to(get_global_mouse_position())
    
    if _reload_left > 0:
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


func fire() -> void:
    var num_shots: int = 1
    var arc_size: float = 0.
    
    for upgrade in UPGRADES:
        match upgrade:
            Modifiers.Gun.SCATTERSHOT:
                arc_size = max(arc_size, PI / 6)
                num_shots += 3
            Modifiers.Gun.RADIAL:
                arc_size = PI
                num_shots += 3
    
    for i in range(num_shots):
        var arc_angle: float = lerp(-arc_size, arc_size, float(i) / (num_shots - 1))
        if arc_size >= PI:
            arc_angle = lerp(0.0, TAU, float(i) / num_shots)
        var bullet: Node2D = BULLET.instantiate()
        bullet.configure(bullet_speed(), bullet_damage())
        PROJECTILE_NODE.add_child(bullet)
        bullet.global_position = BULLET_SPAWN.global_position
        bullet.global_rotation = BULLET_SPAWN.global_rotation + arc_angle
        _fire_cooldown_left = fire_cooldown()
    
    if not Modifiers.Gun.BOTTOMLESS_MAGAZINE in UPGRADES:
        _rounds_left -= 1


func start_reload() -> void:
    _reload_left = reload_time()
    if _reload_left <= 0:
        _rounds_left = magazine_size()
        reload()


func reload() -> void:
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
    return mag_size


func fire_cooldown() -> float:
    var cooldown: float = BASE_FIRE_COOLDOWN
    for upgrade in UPGRADES:
        match upgrade:
            Modifiers.Gun.RAPID_FIRE:
                cooldown = cooldown * 0.5
            Modifiers.Gun.POWERFUL:
                cooldown = cooldown * 1.5
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
    return damage
