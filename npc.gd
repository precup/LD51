extends Area2D

@export var dialog_text = "Hello."
var player_in_area = false

# Called when the node enters the scene tree for the first time.
func _ready():
  $position/click_to_talk_label.visible = false
  $animation.play("pulse")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  $position/click_to_talk_label.visible = player_in_area
  
  if player_in_area:
    if Input.is_action_just_pressed("shoot") and not $"/root/root/ui/dialog".visible:
      $"/root/root/ui/dialog/label".text = dialog_text
      
      await get_tree().process_frame
      get_tree().paused = true
      $"/root/root/ui/dialog".visible = true

func _on_npc_body_entered(body):
  var player = $"/root/root/references".get_player()

  if player == body:
    player_in_area = true

func _on_npc_body_exited(body):
  var player = $"/root/root/references".get_player()

  if player == body:
    player_in_area = false
