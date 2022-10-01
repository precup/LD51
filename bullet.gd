extends Node2D

var _speed: float = 0.
var _damage: float = 0.
var _effects: Array = []
var _target: Node2D = null

func configure(speed: float, damage: float, effects: Array, target: Node2D):
    _speed = speed
    _damage = damage
    _effects = effects
    _target = target


func _process(delta):
    var direction: Vector2 = transform.x
    global_position += direction * _speed * delta
