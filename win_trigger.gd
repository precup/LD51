extends Area2D

func _on_win_trigger_body_entered(body):
  $"/root/root/ui/game_over".play_win_animation()
