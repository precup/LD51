extends HSplitContainer

signal updated

var hovered = false


func set_light(off: bool, color: Color):
  $margin/slot_glow.visible = not off
  $margin/slot_glow.modulate = color
  $margin/slot_orb.modulate = color


func _on_hsplit_mouse_entered():
  hovered = true
  emit_signal("updated")


func _on_hsplit_mouse_exited():
  hovered = false
  emit_signal("updated")
