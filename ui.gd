extends CanvasLayer

@onready var clip_label: Label = $clip_label

func _process(delta):
  var player = $"/root/root/references".get_player()
  var rounds_left = player.get_active_gun().get_rounds_left()

  if rounds_left > 0:
    clip_label.text = "Clip: %d" % player.get_active_gun().get_rounds_left()
  else:
    clip_label.text = "Reloading..."
  
