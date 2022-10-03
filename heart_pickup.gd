extends Node2D

var animation_player: AnimationPlayer
var mat: Material


# Called when the node enters the scene tree for the first time.
func _ready():
  animation_player = $animation_player
  animation_player.play("pulse")
  var s: Sprite2D = $heart_pickup
  var t: Texture2D = s.texture
  mat = s.material
  s.set_material(null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func _on_area_body_entered(body: Node2D):
  if body.has_method("pickup"):
    var s: Sprite2D = $heart_pickup
    s.set_material(mat)
    
    body.pickup("heart")
    $"/root/root/sfx/pickup".play()
    animation_player.play("get")
    
    await animation_player.animation_finished
    
    queue_free()
