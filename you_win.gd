extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
  visible = false

func play_win_animation():
  
  visible = true
  
  var player = $"/root/root/references".get_player()
  get_tree().paused = true
  
  var x: AnimationPlayer

  $animation.play("fade_overlay")
  
  await $animation.animation_finished #wtf there is a bug in the docs that says this takes an arg when in fact it does not!!!?!?
  
  $animation.play("pulse_text")
