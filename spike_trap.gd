extends Area2D

var is_spiky = false
var bodies_in_trap = []

func _ready():
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "trash"
  
  $health_bar.visible = false
  $graphic.visible = true
  $graphic_triggered.visible = false
  
  var label: Label = $countdown
  label.text = "" 
  run_state_machine()

func run_state_machine():
  while true:
    is_spiky = false
    update_graphics()
    
    for x in range(3):
      # $countdown.text = "%d" % x
      
      for tick in range(120):
        await get_tree().process_frame
    
    is_spiky = false
    update_graphics()
    
    $graphic_triggered.visible = true
    $graphic.visible = false
    
    for tick in range(120):
      await get_tree().process_frame
      
      for body in bodies_in_trap:
        # TODO: Don't damage more than once per cycle
        if body.has_method("damage"):
          body.damage(1)

func update_graphics():
  $graphic_triggered.visible = is_spiky
  $graphic.visible = not is_spiky
  # $countdown.visible = not is_spiky


func _on_spike_trap_body_entered(body):
  bodies_in_trap.append(body)

func _on_spike_trap_body_exited(body):
  bodies_in_trap.erase(body)
