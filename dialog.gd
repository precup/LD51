extends ColorRect

var prev_text = "nothing"
var finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if visible:
    if Input.is_action_just_pressed("shoot"):
      if $label.visible_characters != $label.text.length():
        $label.visible_characters = $label.text.length()
        finished = true
        return
      
      await get_tree().process_frame
      visible = false
      get_tree().paused = false
      
      $label.text = ""

    if $label.text != prev_text:
      prev_text = $label.text
      finished = false
      start_text()

func start_text(): 
  for x in range($label.text.length()):
    if finished: 
      return
    var l: Label = $label
    l.visible_characters = x
    
    for wait in range(3):
      await get_tree().process_frame
