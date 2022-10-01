extends Node2D

var direction: Vector2
var shooter: Node
var damage = 1

func initialize(direction: Vector2, shooter: Node, damage: int):
  self.shooter = shooter
  self.direction = direction
  self.damage = damage

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  position += direction * delta * 500


func _on_hit_area_body_entered(body):
  if body.has_method("hit") and body != shooter:
    body.hit(damage)
  
  if body != shooter:
    queue_free()
