extends StaticBody2D

var is_spiky = false

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "trash"
  
  $health_bar.visible = false
  $graphic.visible = true
  $graphic_triggered.visible = false
  
  run_state_machine()

func run_state_machine():
  while true:
    for x in range(3):
      $countdown.text = "%d" % x
      
      for tick in range(60):
        await get_tree().process_frame
    
    $countdown.visible = false
    
    $graphic_triggered.visible = true
    $graphic.visible = false
    
    for tick in range(60):
      await get_tree().process_frame



func update_graphics():
  $graphic_triggered.visible = true
  $graphic.visible = false
