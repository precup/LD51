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

var _upgrade_mode: bool = true
var _upgrade: Modifiers.Gun = Modifiers.Gun.NONE
var _gun = null

func _ready() -> void:
  visible = false


func get_random_upgrade(min_rarity: QuestGlobals.Rarity):
  return Modifiers.Gun.RICOCHET
  

func get_random_gun(min_rarity: QuestGlobals.Rarity):
  var gun = GUN_SCENE.instantiate()
  var max_mods: int = max((randi() % (min_rarity * 2 + 2)), min_rarity + 2)
  gun.MAX_MODIFIERS = max_mods
  gun.UPGRADES = []
  for i in range(max(1, int(ceil(gun.MAX_MODIFIERS / 2.0)))):
    gun.UPGRADES.append(get_random_upgrade(min_rarity))
  return gun


func show_reward(reward_type: QuestGlobals.RewardType, min_rarity: QuestGlobals.Rarity) -> void:
  get_tree().paused = true
  visible = true
  
  NEW_WEAPON.visible = reward_type == QuestGlobals.RewardType.REWARD_GUN
  NEW_UPGRADE.visible = reward_type == QuestGlobals.RewardType.REWARD_MOD
  
  var player_guns: Array = get_tree().get_first_node_in_group("player").get_node("guns").get_children()
  WEAPON1.display_weapon(player_guns[0], reward_type == QuestGlobals.RewardType.REWARD_MOD)
  WEAPON2.display_weapon(player_guns[1], reward_type == QuestGlobals.RewardType.REWARD_MOD)
  
  match reward_type:
    QuestGlobals.RewardType.REWARD_MOD:
      _upgrade_mode = true
      _upgrade = get_random_upgrade(min_rarity)
      UPGRADE_NAME.text = Modifiers.NAMES[_upgrade]
      UPGRADE_DESCRIPTION.text = Modifiers.DESCRIPTIONS[_upgrade]
      HEADER.text = "New Wand Upgrade!"
      OPTION_HEADER.text = "Pick a wand to upgrade:"
      _gun = null
      
    QuestGlobals.RewardType.REWARD_GUN:
      _upgrade_mode = false
      _gun = get_random_gun(min_rarity)
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
  apply_to_weapon(0)


func _on_weapon_2_clicked():
  apply_to_weapon(1)


func apply_to_weapon(i):
  var gun_node = get_tree().get_first_node_in_group("player").get_node("guns")
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
  if not _upgrade_mode:
    _gun.visible = false
  close_menu()
