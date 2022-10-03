extends Area2D

var is_last_active = false

func _on_checkpoint_body_entered(body):
  if is_last_active:
    return
  
  var player = $"/root/root/references".get_player()
  
  if body == player:
    var checkpoints = get_tree().get_nodes_in_group("checkpoint")
    
    for point in checkpoints:
      point.is_last_active = false
    
    is_last_active = true
