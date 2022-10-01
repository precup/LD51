extends Node2D

var animation_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
  animation_player = $animation_player
  animation_player.play("pulse")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func _on_area_body_entered(body: Node2D):
  if body.has_method("pickup"):
    body.pickup("heart")
    
    queue_free()
