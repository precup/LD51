extends Area2D

func _on_win_trigger_body_entered(body):
  var player = $"/root/root/references".get_player()
  
  if body == player:
    $"/root/root/ui/game_over".play_win_animation()
