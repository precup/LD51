extends Area2D

@export var dialog_text: Array[String] = ["Hello."]
var player_inside = false

func _ready():
  $position.visible = false

func _process(_delta):
  if player_inside and Input.is_action_just_pressed("shoot"):
    await get_tree().process_frame
    
    if not $"/root/root/ui/dialog".visible:
      player_inside = false # hack to not immediately retrigger
      
      await get_tree().process_frame
      get_tree().paused = true
      
      $"/root/root/ui/dialog".start_dialog(dialog_text)
      $"/root/root/ui/dialog".visible = true

func _on_npc_body_entered(body):
  var player = $"/root/root/references".get_player()
  if player == body:
    player_inside = true
    $position.visible = true
    $animation.play("pulse")


func _on_npc_body_exited(body):
  var player = $"/root/root/references".get_player()
  if player == body:
    player_inside = false
    $position.visible = false
    $animation.stop()
