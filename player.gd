extends CharacterBody2D

var speed = 400

func _ready():
  pass

func _process(_delta):
  # Move character when the user presses the arrow keys.

  var direction = Input.get_vector(
    "ui_left", 
    "ui_right",
    "ui_up",
    "ui_down"
  ) * 300

  velocity = direction

  move_and_slide()
