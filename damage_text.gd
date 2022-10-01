extends Label

var ticks = 0

func _process(delta):
  ticks += 1
  
  position += Vector2(0, -1)
  
  if ticks == 100:
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.4)
    tween.tween_callback(queue_free)
