extends PanelContainer

signal clicked

@export var CLICKABLE: bool = true
@export var IS_TRASH: bool = false

@onready var SLOT_PARENT: VBoxContainer = $split/panel/scroll/margin/center/vbox
var maxed_out: bool = false

func _ready():
  if IS_TRASH:
    $split/gun_icon.texture = load("res://assets/trash_icon.png")
    $split/panel.visible = false
  $highlight.visible = false

func display_weapon(gun, can_max_out: bool):
  var max_slots: int = gun.MAX_MODIFIERS
  var upgrades: Array = gun.UPGRADES
  maxed_out = max_slots <= len(upgrades) and can_max_out
  $unselectable.visible = maxed_out
  while SLOT_PARENT.get_child_count() < max_slots:
    var new_slot = SLOT_PARENT.get_child(0).duplicate(DuplicateFlags.DUPLICATE_SIGNALS)
    SLOT_PARENT.add_child(new_slot)
  for i in range(max(1, max_slots), SLOT_PARENT.get_child_count()):
    SLOT_PARENT.get_child(i).queue_free()
  SLOT_PARENT.get_child(0).visible = max_slots > 0
  
  for i in range(max_slots):
    var slot = SLOT_PARENT.get_child(i)
    slot.get_node("hsplit/mod_name").text = Modifiers.NAMES[upgrades[i]] if i < len(upgrades) else ""
    slot.get_node("hsplit/full_icon").visible = i < len(upgrades)
    slot.get_node("hsplit/empty_icon").visible = i >= len(upgrades)


func _input(event):
  if event is InputEventMouseButton:
    if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and CLICKABLE and not maxed_out and $highlight.visible:
      emit_signal("clicked")


func _on_weapon_display_mouse_entered():
  if CLICKABLE and not maxed_out:
    $highlight.visible = true


func _on_weapon_display_mouse_exited():
  $highlight.visible = false
