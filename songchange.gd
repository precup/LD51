extends Area2D



func _on_area_2d_body_entered(body):
  var player = get_tree().get_first_node_in_group("player")
  if player and player == body:
    get_tree().get_first_node_in_group("oldmusic").playing = false
    get_tree().get_first_node_in_group("newmusic").playing = true
    queue_free()
