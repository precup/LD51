extends Node2D

func _ready():
  scale = Vector2(1.5, 1.5)

func _process(delta):
  modulate.a -= 0.03
  scale += Vector2(0.05, 0.05)

func _on_animated_sprite_animation_finished():
  queue_free()
 


func _on_npc_body_exited(body):
  pass # Replace with function body.
