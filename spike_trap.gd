extends Area2D

var is_spiky = false
var bodies_in_trap = []
@export var STARTING_TIME: float = 0.0
@export var UP_TIME: float = 2.0
@export var DOWN_TIME: float = 6.0
var state_ttl: float = 0

# countdown looks pretty ugly and seems unnecessary imo!

func _ready():
  var start_time: float = fmod(STARTING_TIME, UP_TIME + DOWN_TIME)
  
  if start_time > DOWN_TIME:
    state_ttl = UP_TIME + DOWN_TIME - start_time
    is_spiky = true
    $static_body/shape.disabled = false
  else:
    state_ttl = DOWN_TIME - start_time
    is_spiky = false
    $static_body/shape.disabled = false
  
  $base_enemy._max_health = 4
  $base_enemy._health = 4
  $base_enemy._item_drop_type = "trash"
  
  $health_bar.visible = false
  $sprite.play("unspike")
  
  var label: Label = $countdown
  label.text = "" 

func _physics_process(delta):
  if state_ttl - delta < 0:
    is_spiky = not is_spiky
    
    if is_spiky:
      state_ttl = UP_TIME
      $static_body/shape.disabled = bodies_in_trap.size() != 0
    else:
      state_ttl = DOWN_TIME
      $static_body/shape.disabled = true
      
    update_graphics()
  else:
    state_ttl -= delta
  
  if is_spiky:
    for body in bodies_in_trap:
        # TODO: Only damage once per cycle
        
        if body.has_method("damage"):
          var kb_vec = (global_position - body.global_position).normalized()
          body.damage(-1, kb_vec)


func update_graphics():
  if is_spiky and $sprite.animation != "spike":
    $sprite.play("spike")
  elif not is_spiky and $sprite.animation != "unspike":
    $sprite.play("unspike")


func _on_spike_trap_body_entered(body):
  bodies_in_trap.append(body)


func _on_spike_trap_body_exited(body):
  bodies_in_trap.erase(body)
