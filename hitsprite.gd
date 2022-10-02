extends Node2D

func _process(delta):
  modulate.a -= 0.03


func _on_animated_sprite_animation_finished():
  queue_free()
