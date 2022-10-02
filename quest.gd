extends Node

class_name Quest

@onready var ui_description_text : RichTextLabel = $HSplit/VSplit/Margin1/Label
@onready var ui_progress_bar : ProgressBar = $HSplit/VSplit/Margin2/ProgressBar
@onready var ui_progress_text : RichTextLabel = $HSplit/VSplit/Margin2/ProgressBar/Progress
@onready var ui_reward_type_icon : TextureRect = $HSplit/Margin/Center/RewardIcon
@onready var ui_quest_complete_overlay : ColorRect = $CompletedQuestOverlay
@onready var ui_background : ColorRect = $BackgroundStyle
@onready var ui_quest_complete_overlay2 : TextureRect = $TextureRect
const REWARD_ICON_RESOURCES: Dictionary = {
  QuestGlobals.RewardType.REWARD_GUN: "res://assets/gun_reward_icon.png",
  QuestGlobals.RewardType.REWARD_MOD: "res://assets/mod_reward_icon.png",
  QuestGlobals.RewardType.REWARD_OTHER: "res://assets/misc_reward_icon.png"
}
const RARITY_COLORS: Dictionary = {
  QuestGlobals.Rarity.RARITY_COMMON: Color(0.0,0.0,0.0,164.0/255.0),
  QuestGlobals.Rarity.RARITY_RARE: Color(22.0/255.0,22.0/255.0,135.0/255.0,164.0/255.0),
  QuestGlobals.Rarity.RARITY_LEGENDARY: Color(106.0/255.0,65.0/255.0,8.0/255.0,164.0/255.0)
}

var reward
var quest_rarity =  QuestGlobals.Rarity.RARITY_COMMON
var is_completed = false

var stat_being_tracked = QuestGlobals.StatTrack.STAT_DO_NOTHING
var stat_count_required = 1
var stat_count_current = 0

var is_accumulating_duration = false
var sub_second_timer = 0.0
const DURATION_INITIAL_DELAY = .2 # wait 200ms before starting/unpausing the duration counter
var initial_delay_counter = 0.0


# TODO: Get UI to dynamically update

# TODO: may need to display more details about rewards


func initialize(_reward, _quest_rarity, _description, _stat_being_tracked, _stat_count_required):
  reward = _reward
  quest_rarity = _quest_rarity
  ui_background.color = RARITY_COLORS[quest_rarity]
  ui_description_text.text = _description
  ui_progress_bar.max_value = _stat_count_required
  stat_being_tracked = _stat_being_tracked
  stat_count_required = _stat_count_required
  ui_reward_type_icon.texture = load(REWARD_ICON_RESOURCES[reward.reward_type])
  _update_progress()


func _process(delta):
  if (is_accumulating_duration && !is_completed):
    # Add the delta to initial delay, or actual counter accordingly
    if initial_delay_counter < DURATION_INITIAL_DELAY:
      initial_delay_counter += delta
    else:      
      sub_second_timer += delta
      if (sub_second_timer >= 1.0):
        sub_second_timer -= 1
        _increment_current_count(1) 
  
func _update_progress():
  ui_progress_text.text = str(stat_count_current, " of ", stat_count_required)

func _increment_current_count(amount):
  stat_count_current += amount
  _update_progress()
  ui_progress_bar.value = stat_count_current
    
  if stat_count_current >= stat_count_required:
    is_completed = true
    ui_quest_complete_overlay.visible = true
    ui_quest_complete_overlay2.visible = true
    reward.execute.call()
    
    
func quest_count_progress(stat_track_id, amount):
  if stat_track_id == stat_being_tracked && !is_completed:
    _increment_current_count(amount)


# This is for stats that involve continuity (do __ without doing __)
func quest_reset_progress_count(stat_track_id):
  if stat_track_id == stat_being_tracked && !is_completed:
    stat_count_current = 0    
    ui_progress_bar.value = stat_count_current
    initial_delay_counter = 0.0 # probably dont need this here, but whatever
    _update_progress()


# For stats that involve duration
func quest_start_timer(stat_track_id):
  if stat_track_id == stat_being_tracked && !is_completed:
    is_accumulating_duration = true


# If the duration does not need to be continuous
func quest_pause_timer(stat_track_id):
  if stat_track_id == stat_being_tracked && !is_completed:
    is_accumulating_duration = false
    initial_delay_counter = 0.0 


# For if the duration must be continous
func quest_reset_timer(stat_track_id):
  if stat_track_id == stat_being_tracked && !is_completed:
    is_accumulating_duration = false
    stat_count_current = 0  # reset progress on stop duration
    ui_progress_bar.value = stat_count_current
    initial_delay_counter = 0.0 
    _update_progress()
