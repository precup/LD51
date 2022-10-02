extends Node2D

var is_debug = true

# handy list of all references!

@export var player: NodePath
var _player: Node2D = null

# Is this stupid sort of thing even necessary? I blame unity for this paranoia.

func get_player():
  if _player == null: _player = get_node(player)
  return _player
