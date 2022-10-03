extends HBoxContainer

var player: Player
var cur_health = 0
var cur_max_health = 0
var active_heart: Node2D = null

func _ready():
  player = get_tree().get_first_node_in_group("player")


func _process(delta):
  var next_health = player.health()
  var next_max_health = player.max_health()
  
  if cur_health != next_health or cur_max_health != next_max_health:
    cur_health = next_health
    cur_max_health = next_max_health
    
    update_hearts()

func update_hearts():
  var health = player.health()
  var max_health = player.max_health()
  var hearts = get_children()
  
  var health_left = health
  var next_active_heart: Node2D = null
  
  for i in range(hearts.size()):
    var heart = hearts[i]

    for child in heart.get_children():
      if child.name == "animation_player":
        continue
        
      var heart_sprite: TextureRect = child

      child.visible = false
    
    if health_left <= 2 and health_left > 0:
      next_active_heart = heart
    
    if health_left >= 2:
      heart.get_node("heart_full").visible = true
    elif health_left >= 1:
      heart.get_node("heart_half").visible = true
    else: 
      heart.get_node("heart_empty").visible = true
      
    health_left -= 2
  
  if next_active_heart != active_heart:
    for i in range(hearts.size()):
      var heart = hearts[i]
      heart.get_node("animation_player").seek(0, true)
      heart.get_node("animation_player").stop()

    if next_active_heart != null:
      next_active_heart.get_node("animation_player").play("pulse")
