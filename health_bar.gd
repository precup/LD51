extends Node2D

var current_health = 0
var damage_text_scene = preload("res://damage_text.tscn")

func _ready():
  modulate = Color.TRANSPARENT

# expected that the parent calls this once per tick
func update(health, max_health):
  var graphic = $graphic

  graphic.scale = Vector2(float(health) / float(max_health), 0.3)

  if current_health != health and current_health != 0:
    current_health = health
    self.modulate = Color.WHITE
    eventually_fade_out()
    
    var damage_amount = health - current_health
    var new_damage_text = damage_text_scene.instantiate()
    
    new_damage_text.position = position

    get_parent().add_child(new_damage_text)
  
  current_health = health

func eventually_fade_out():
  var health_when_changed = current_health

  for x in range(150):
    if health_when_changed != current_health:
      return

    await get_tree().process_frame
  
  # fade out after 1 second
  var tween = create_tween()
  
  if health_when_changed == current_health:
    tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.4)
