extends Control

@onready var weapon1 = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HSplitContainer/weapon_display
@onready var weapon2 = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HSplitContainer/weapon_display2

var has_shown: bool = false

func _process(__delta):
  if not has_shown:
    if $"/root/root/references".is_debug:
      has_shown = true
      visible = false
      return

    has_shown = true
    var player = get_tree().get_first_node_in_group("player")
    var guns = player.get_node("gun_rotation_container/guns")
    assert(guns.get_child_count() == 2)
    weapon1.display_weapon(guns.get_child(0), false)
    weapon2.display_weapon(guns.get_child(1), false)
    get_tree().paused = true
    visible = true



func _on_button_pressed():
  get_tree().paused = false
  visible = false
