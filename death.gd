extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
  visible = false

func play_death_animation():
  visible = true
  
  var player = $"/root/root/references".get_player()
  get_tree().paused = true
  
  var x: AnimationPlayer

  $animation.play("fade_overlay")
  
  await $animation.animation_finished #wtf there is a bug in the docs that says this takes an arg when in fact it does not!!!?!?
  
  $animation.play("pulse_text")
  
  while true:
    await get_tree().process_frame
    
    if Input.is_action_just_pressed("action"):
      break
  
  # don't open the gun dlg by accident
  await get_tree().process_frame
  await get_tree().process_frame
  
  visible = false
  
  var checkpoints = get_tree().get_nodes_in_group("checkpoint")
  
  for point in checkpoints:
    if point.is_last_active:
      player.global_position = point.global_position
      break
  
  get_tree().paused = false
  player._health = player.MAX_HEALTH
