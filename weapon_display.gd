extends PanelContainer

signal clicked

@export var CLICKABLE: bool = true
@export var IS_TRASH: bool = false

@onready var SLOT_PARENT: VBoxContainer = $split/panel/scroll/margin/center/vbox
@onready var GUN_ICON: TextureRect = $split/margin/gun_icon
@onready var TOOLTIP = $split/margin/margin
@onready var TOOLTIP_TEXT = $split/margin/margin/panel/margin/description

var maxed_out: bool = false
var is_modding = false
var background_style_box : StyleBoxFlat
var _gun = null
var _mod = null

func _ready():
  if get_parent().has_node("trashimg"):
    get_parent().get_node("trashimg").visible = false
  
  if IS_TRASH:
    GUN_ICON.texture = load("res://assets/trash_icon.png")
    $split/margin/gun_icon2.visible = false
    $split/panel.visible = false
  $highlight.visible = false
  
  var old_style : StyleBoxFlat= get("theme_override_styles/panel")
  var new_style = old_style.duplicate()
  background_style_box = new_style
  set('theme_override_styles/panel', new_style)

func display_weapon(gun, can_max_out: bool, is_gun_time: bool, mod: Modifiers.Gun):
  if not is_gun_time and mod != Modifiers.Gun.NONE:
    _gun = gun
    _mod = mod
  else: 
    _gun = null
    _mod = null
  $highlight.get_child(0).visible = is_gun_time
  $highlight.visible = false 
  
  var max_slots: int = gun.MAX_MODIFIERS
  while SLOT_PARENT.get_child_count() < max_slots:
    var new_slot = SLOT_PARENT.get_child(0).duplicate(DuplicateFlags.DUPLICATE_SIGNALS | DuplicateFlags.DUPLICATE_SCRIPTS)
    SLOT_PARENT.add_child(new_slot)
  for i in range(max(1, max_slots), SLOT_PARENT.get_child_count()):
    SLOT_PARENT.get_child(i).queue_free()
  SLOT_PARENT.get_child(0).visible = max_slots > 0
  
  background_style_box.set_bg_color(QuestGlobals.RARITY_COLORS_BACK[gun.RARITY])
  
  for i in range(max_slots):
    var slot = SLOT_PARENT.get_child(i)
    slot.get_child(0).hovered = false
    
  _display_weapon(gun, can_max_out, is_gun_time, Modifiers.Gun.NONE)
  _on_hsplit_updated()
  GUN_ICON.modulate = gun.COLOR


func _display_weapon(gun, can_max_out: bool, is_gun_time: bool, mod: Modifiers.Gun):
  var max_slots: int = gun.MAX_MODIFIERS
  var upgrades: Array = gun.UPGRADES.duplicate()
  maxed_out = max_slots <= len(upgrades) and can_max_out
  $unselectable.visible = maxed_out
  if mod != Modifiers.Gun.NONE and not maxed_out:
    upgrades.append(mod)
  
  for i in range(max_slots):
    var slot = SLOT_PARENT.get_child(i)
    slot.get_node("hsplit/mod_name").text = Modifiers.NAMES[upgrades[i]] if i < len(upgrades) else ""
    slot.get_node("hsplit/mod_name").set("theme_override_colors/font_color", QuestGlobals.RARITY_COLORS_TEXT[Modifiers.RARITIES[upgrades[i]]] if i < len(upgrades) else null)
    slot.get_node("hsplit").set_light(i >= len(upgrades), Color(0.4, 0.4, 0.4) if i >= len(upgrades) else QuestGlobals.RARITY_COLORS_TEXT[Modifiers.RARITIES[upgrades[i]]])
  

func _input(event):
  if event is InputEventMouseButton:
    if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and CLICKABLE and not maxed_out and get_node("highlight").visible:
      emit_signal("clicked")

func clear_highlights():
  $highlight.visible = false
  if _gun != null:
    _display_weapon(_gun, true, false, Modifiers.Gun.NONE)
  
func _on_weapon_display_mouse_entered():
  if CLICKABLE and not maxed_out:
    $highlight.visible = true
    if _gun != null:
      _display_weapon(_gun, true, false, _mod)

func _on_weapon_display_mouse_exited():
  clear_highlights()

func _on_hsplit_updated():
  var hovered = null
  for slot in SLOT_PARENT.get_children():
    if slot.get_child(0).hovered:
      hovered = slot.get_child(0)
  TOOLTIP.visible = hovered != null
  if hovered:
    var mod_name = hovered.get_node("mod_name").text
    var mod = null
    for poss_mod in Modifiers.Gun.values():
      if poss_mod in Modifiers.NAMES and Modifiers.NAMES[poss_mod] == mod_name:
        mod = poss_mod
    TOOLTIP_TEXT.text = Modifiers.DESCRIPTIONS[mod] if mod != null else "Empty slot (for a mod)."
    
