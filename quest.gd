extends Node

class_name Quest

var reward
var quest_rarity =  QuestGlobals.Rarity.RARITY_COMMON
var is_completed = false
var description = "test"

var stat_being_tracked = QuestGlobals.StatTrack.STAT_DO_NOTHING
var stat_count_required = 1
var stat_count_current = 0
var stat_count_max_seen = 0

var is_accumulating_duration = false
var sub_second_timer = 0.0
const DURATION_INITIAL_DELAY = .2 # wait 200ms before starting/unpausing the duration counter
var initial_delay_counter = 0.0


# TODO: Get UI to dynamically update

# TODO: may need to display more details about rewards

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.
  
func initialize(_reward, _quest_rarity, _description, _stat_being_tracked, _stat_count_required):
  reward = _reward
  quest_rarity = _quest_rarity
  description = _description
  stat_being_tracked = _stat_being_tracked
  stat_count_required = _stat_count_required
  
# Called every frame. 'delta' is the elapsed time since the previous frame.
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
      
func _increment_current_count(amount):
  stat_count_current += amount
  if (stat_count_current > stat_count_max_seen):
    stat_count_max_seen = stat_count_current 
    
  if stat_count_current >= stat_count_required:
    is_completed = true
    reward.execute.call()
    
    
func quest_count_progress(stat_track_id, amount):
  if stat_track_id == stat_being_tracked && !is_completed:
    _increment_current_count(amount)
  
# This is for stats that involve continuity (do __ without doing __)
func quest_reset_progress_count(stat_track_id):
  if stat_track_id == stat_being_tracked && !is_completed:
    stat_count_current = 0
    initial_delay_counter = 0.0 # probably dont need this here, but whatever

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
func quest_stop_timer(stat_track_id):
  if stat_track_id == stat_being_tracked && !is_completed:
    is_accumulating_duration = false
    stat_count_current = 0  # reset progress on stop duration
    initial_delay_counter = 0.0 
