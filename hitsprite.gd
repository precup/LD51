extends Node2D

func _ready():
  scale = Vector2(1, 1)

func _process(delta):
  modulate.a -= 0.03
  scale += Vector2(0.05, 0.05)

func _on_animated_sprite_animation_finished():
  queue_free()
 
