extends Control

@onready var HEADER: Label = $center/panel/vsplit/margin/vbox/header
@onready var OPTION_HEADER: Label = $center/panel/vsplit/margin2/vsplit/option_header
@onready var NEW_WEAPON = $center/panel/vsplit/margin/vbox/center/margin/new_weapon
@onready var NEW_UPGRADE = $center/panel/vsplit/margin/vbox/center/margin/hsplit
@onready var UPGRADE_NAME = $center/panel/vsplit/margin/vbox/center/margin/hsplit/vsplit/name
@onready var UPGRADE_DESCRIPTION = $center/panel/vsplit/margin/vbox/center/margin/hsplit/vsplit/description

var _upgrade_mode: bool = true
var _upgrade: Modifiers.Gun = Modifiers.Gun.NONE
var _gun_slots: int = 1
var _gun_mods: Array = []

func _ready() -> void:
  visible = false


func get_random_upgrade(min_rarity: QuestGlobals.Rarity):
  return Modifiers.Gun.RICOCHET
  

func get_random_max_slots(min_rarity: QuestGlobals.Rarity) -> int:
  return 2
  

func get_random_filled_slots(min_rarity: QuestGlobals.Rarity, max_slots: int) -> int:
  return 1


func show_reward(reward_type: QuestGlobals.RewardType, min_rarity: QuestGlobals.Rarity) -> void:
  get_tree().paused = true
  visible = true
  
  NEW_WEAPON.visible = reward_type == QuestGlobals.RewardType.REWARD_GUN
  NEW_UPGRADE.visible = reward_type == QuestGlobals.RewardType.REWARD_MOD
  
  match reward_type:
    QuestGlobals.RewardType.REWARD_MOD:
      _upgrade_mode = true
      _upgrade = get_random_upgrade(min_rarity)
      UPGRADE_NAME.text = Modifiers.NAMES[_upgrade]
      UPGRADE_DESCRIPTION.text = Modifiers.DESCRIPTIONS[_upgrade]
      HEADER.text = "New Wand Upgrade!"
      OPTION_HEADER.text = "Pick a wand to upgrade:"
      
    QuestGlobals.RewardType.REWARD_GUN:
      _upgrade_mode = false
      _gun_slots = get_random_max_slots(min_rarity)
      _gun_mods = []
      for i in range(get_random_filled_slots(min_rarity, _gun_slots)):
        _gun_mods.append(get_random_upgrade(min_rarity))
      HEADER.text = "New Wand!"
      OPTION_HEADER.text = "Pick a wand to replace:"
      
    QuestGlobals.RewardType.REWARD_OTHER:
      close_menu()


func close_menu() -> void:
  get_tree().paused = false
  visible = false


func _on_weapon_1_clicked():
  print("weapon 1 chosen")
  close_menu()


func _on_weapon_2_clicked():
  print("weapon 2 chosen")
  close_menu()


func _on_trash_clicked():
  print("trash chosen")
  close_menu()
