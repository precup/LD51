extends Control

const GUN_SCENE: PackedScene = preload("res://gun.tscn")

@onready var HEADER: Label = $center/panel/vsplit/margin/vbox/header
@onready var OPTION_HEADER: Label = $center/panel/vsplit/margin2/vsplit/option_header
@onready var NEW_WEAPON = $center/panel/vsplit/margin/vbox/center/margin/new_weapon
@onready var NEW_UPGRADE = $center/panel/vsplit/margin/vbox/center/margin/hsplit
@onready var UPGRADE_NAME = $center/panel/vsplit/margin/vbox/center/margin/hsplit/vsplit/name
@onready var UPGRADE_DESCRIPTION = $center/panel/vsplit/margin/vbox/center/margin/hsplit/vsplit/description

@onready var WEAPON1 = $center/panel/vsplit/margin2/vsplit/hbox/margin/weapon1
@onready var WEAPON2 = $center/panel/vsplit/margin2/vsplit/hbox/margin2/weapon2
@onready var TRASH = $center/panel/vsplit/margin2/vsplit/hbox/margin3/trash

var _upgrade_mode: bool = true
var _upgrade: Modifiers.Gun = Modifiers.Gun.NONE
var _gun = null

var _gun_mods_by_rarity = {}

func _ready() -> void:
  visible = false 

func _init():
  _sort_mods_by_rarity()
    
func _sort_mods_by_rarity():
  for rarity in QuestGlobals.Rarity.values():
    _gun_mods_by_rarity[rarity] = []
    
  for mod in Modifiers.RARITIES:
    if mod != Modifiers.Gun.NONE:
      _gun_mods_by_rarity[Modifiers.RARITIES[mod]].append(mod)


func get_random_upgrade(rarity_weights: Dictionary):
  
  var total = rarity_weights.values().reduce(func(i,accum): return accum + i)
  var my_random_number = randi_range(0, total-1)
  
  var selected_rarity = QuestGlobals.Rarity.RARITY_COMMON
  for rarity in rarity_weights:
    my_random_number -= rarity_weights[rarity]
    if my_random_number < 0:
      selected_rarity = rarity
      break
  
  var selected_mod = _gun_mods_by_rarity[selected_rarity][randi_range(0, len(_gun_mods_by_rarity[selected_rarity])-1)]
  
  return selected_mod
  
func get_random_starter_gun(with_mod : bool):
  var gun = GUN_SCENE.instantiate()
  gun.MAX_MODIFIERS = 2
  gun.UPGRADES = []
  gun.COLOR = Color.from_hsv(randf(), 0.5, 1.0)
  if with_mod:  # one of their guns gets a mod, one doesnt
    gun.UPGRADES.append(get_random_upgrade({QuestGlobals.Rarity.RARITY_COMMON: 1})) # Heavily bias starter weapon mod to be a common
  return gun
  
func get_random_gun(gun_rarity: QuestGlobals.Rarity, mod_rarity_weights: Dictionary):
  var gun = GUN_SCENE.instantiate()
  var max_mods: int = max((randi() % (gun_rarity * 2 + 3)), gun_rarity + 1 + (randi() % 2) + (randi() % 2)) # You always get your gun rarity + 1. Then you basically get two rolls at increases
  # Common  Max(0-2, 1-3)
  # Rare    Max(0-4, 2-4) 
  # Legendary  Max(0-6, 3-5) 
  gun.MAX_MODIFIERS = max_mods
  gun.UPGRADES = []
  gun.COLOR = Color.from_hsv(randf(), 0.5, 1.0)
  
  # prefilled mod counts:
    # Common 0-2   (will get clipped to >=1)
    # Rare   1-2
    # Legendary   2-3
  var free_mod_count = randi_range(gun_rarity, int(floor(gun.MAX_MODIFIERS / 2.1))) + (randi() % 2)
  # Clip free mods to be between 1 and max mods-1. In some cases this is [1,1] 
  free_mod_count = max(1, min(max_mods - 1, free_mod_count))
  for i in range(free_mod_count):
    gun.UPGRADES.append(get_random_upgrade(mod_rarity_weights)) 
  return gun

func show_reward(reward_type: QuestGlobals.RewardType, reward_rarity: QuestGlobals.Rarity, base_rarity_weights: Dictionary) -> void:
  get_tree().paused = true
  visible = true
  
  NEW_WEAPON.visible = reward_type == QuestGlobals.RewardType.REWARD_GUN
  NEW_UPGRADE.visible = reward_type == QuestGlobals.RewardType.REWARD_MOD
  
  var player_guns: Array = get_tree().get_first_node_in_group("player").get_node("gun_rotation_container/guns").get_children()
  WEAPON1.display_weapon(player_guns[0], reward_type == QuestGlobals.RewardType.REWARD_MOD)
  WEAPON2.display_weapon(player_guns[1], reward_type == QuestGlobals.RewardType.REWARD_MOD)
  TRASH.clear_highlights()
  
  # mutate the base_rarity_weights table based on reward rarity. Mods of the reward rarity tier are twice as likely. Mods of lower tiers are .5x per tier lower  
  # DO NOT MODIFY base rarity weights, its not a copy... lol
  var reward_rarity_adjusted_mod_weights = {}
  for rarity in QuestGlobals.Rarity.values():
    if rarity < reward_rarity:
      reward_rarity_adjusted_mod_weights[rarity] = base_rarity_weights[rarity] * pow(.5, reward_rarity - rarity) #lower rarities than the gun rarity are halved. doubly so for common on a legendary
    elif rarity == reward_rarity:
      reward_rarity_adjusted_mod_weights[rarity] = base_rarity_weights[rarity] *  2
    else:
      reward_rarity_adjusted_mod_weights[rarity] = base_rarity_weights[rarity]
      
  match reward_type:
    QuestGlobals.RewardType.REWARD_MOD:
      _upgrade_mode = true
      _upgrade = get_random_upgrade(reward_rarity_adjusted_mod_weights)
      UPGRADE_NAME.text = Modifiers.NAMES[_upgrade]
      UPGRADE_DESCRIPTION.text = Modifiers.DESCRIPTIONS[_upgrade]
      HEADER.text = "New Wand Upgrade!"
      OPTION_HEADER.text = "Pick a wand to upgrade:"
      _gun = null
      
    QuestGlobals.RewardType.REWARD_GUN:
      _upgrade_mode = false
      _gun = get_random_gun(reward_rarity, reward_rarity_adjusted_mod_weights)
      NEW_WEAPON.display_weapon(_gun, false)
      HEADER.text = "New Wand!"
      OPTION_HEADER.text = "Pick a wand to replace:"
      _upgrade = Modifiers.Gun.NONE
      
    QuestGlobals.RewardType.REWARD_OTHER:
      close_menu()


func close_menu() -> void:
  get_tree().paused = false
  visible = false


func _on_weapon_1_clicked():
  print("You clicked gun 1")
  apply_to_weapon(0)


func _on_weapon_2_clicked():
  print("You clicked gun 2")
  apply_to_weapon(1)


func apply_to_weapon(i):
  var gun_node = get_tree().get_first_node_in_group("player").get_node("gun_rotation_container/guns")
  var old_gun = gun_node.get_child(i)
  if _upgrade_mode:
    old_gun.UPGRADES.append(_upgrade)
  else:
    _gun.PROJECTILE_NODE = old_gun.PROJECTILE_NODE
    old_gun.add_sibling(_gun)
    _gun.visible = old_gun.visible
    old_gun.visible = false
    gun_node.remove_child(old_gun)
  close_menu()

func _on_trash_clicked():
  print("You clicked trash")
  if not _upgrade_mode:
    _gun.visible = false
  close_menu()
