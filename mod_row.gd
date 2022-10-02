extends HSplitContainer

signal updated

var hovered = false


func _on_hsplit_mouse_entered():
  if $mod_name.text != "":
    hovered = true
    emit_signal("updated")


func _on_hsplit_mouse_exited():
  hovered = false
  emit_signal("updated")
