extends Node2D

var stopped = false
var tick = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  tick += 1
  
  if not stopped:
    var player = $"/root/root/references".get_player()
    $dash_line.set_point_position(1, to_local(player.global_position))

  if not stopped and tick > 8:
    stop()

func stop():
  var line: Line2D = $dash_line
  stopped = true
  
  for x in range(15, 0, -1):
    line.default_color.a = float(x) / 15.0
    await get_tree().process_frame
    
  queue_free()
