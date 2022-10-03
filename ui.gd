extends CanvasLayer

@onready var clip_label: Label = $bottom_left/panel/margin/vsplit/margin/clip_label
@onready var clip_label2: Label = $bottom_left/panel/margin/vsplit/margin/clip_label3
@onready var overlay: TextureRect = $bottom_left/panel/margin/vsplit/margin2/overlay
@onready var gun_icon: TextureRect = $bottom_left/panel/margin/vsplit/margin2/margin/center/gun_image

func _ready():
  $dialog.visible = false
  _process(0)

func _process(delta):
  var player = $"/root/root/references".get_player()
  var gun = player.get_active_gun()
  var reload_progress = gun.get_reload_progress()
  
  gun_icon.modulate = gun.COLOR
  
  overlay.visible = reload_progress >= 0
  overlay.custom_minimum_size.y = (1 - reload_progress) * 148
  
  var rounds_left = gun.get_rounds_left()
  var mag_size = str(gun.magazine_size())

  var rl_label
  if reload_progress < 0:
    rl_label = str(rounds_left)
  else:
    rl_label = "-"
  
  while len(rl_label) < len(mag_size):
    rl_label = " " + rl_label
  clip_label.text = rl_label
  clip_label2.text = mag_size
  
