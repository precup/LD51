extends Node2D

var direction: Vector2
var shooter: Node

func initialize(direction: Vector2, shooter: Node):
  self.shooter = shooter
  self.direction = direction

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  position += direction * delta * 500


func _on_hit_area_body_entered(body):
  if body.name == "enemy":
    body.hit()
  
  if body.has_method("hit") and body != shooter:
    body.hit()
    
    queue_free()
