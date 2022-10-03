extends Area2D

@export var dialog_text: Array[String] = ["Hello."]
var triggered = false

func _on_npc_body_entered(body):
  if triggered:
    return
  
  var player = $"/root/root/references".get_player()

  if player == body:
    if not $"/root/root/ui/dialog".visible:
      triggered = true
      
      await get_tree().process_frame
      get_tree().paused = true
      
      $"/root/root/ui/dialog".start_dialog(dialog_text)
      $"/root/root/ui/dialog".visible = true

func _on_npc_body_exited(body):
  pass
