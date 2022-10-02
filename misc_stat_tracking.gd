extends Node

@onready var quest_manager = $"/root/quest_manager"

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  
  # Restart the do nothing quest if anything was pressed
  if Input.is_anything_pressed():
    quest_manager.quest_reset_timer(QuestGlobals.StatTrack.STAT_DO_NOTHING)  # can change this to a pause if it is too difficult currently
    quest_manager.quest_start_timer(QuestGlobals.StatTrack.STAT_DO_NOTHING)
    
  # Restart the quest if they stop firing
  if Input.is_action_just_pressed("shoot"):
    quest_manager.quest_start_timer(QuestGlobals.StatTrack.STAT_DO_NOTHING)
  if Input.is_action_just_released("shoot"):
    quest_manager.quest_reset_timer(QuestGlobals.StatTrack.STAT_CONTINUOUSLY_FIRE) 
  
      
# annoying to add A B Start, so skipping those lol
var KONAMI_CODE = ["up", "up", "down", "down", "left", "right", "left", "right"]
var IMANOK_CODE = ["right", "left", "right", "left", "down", "down", "up", "up"]

var konami_counter = 0
var imanok_counter = 0
      
  STAT_CONTINUOUSLY_FIRE,
  STAT_CONTINUOUSLY_TOUCH_WALL,

# No clue if this works
func _input(event :InputEvent):
  if event.is_pressed():
    quest_manager.quest_count_progress(QuestGlobals.StatTrack.STAT_KEY_PRESSED)
    
  if event.is_action_pressed(KONAMI_CODE[konami_counter]):
    konami_counter+=1
    if konami_counter >= len(KONAMI_CODE):
      konami_counter = 0
      quest_manager.quest_counter_progress(QuestGlobals.StatTrack.STAT_KONAMI_CODE)
  else:
    konami_counter = 0
    if event.is_action_pressed(KONAMI_CODE[konami_counter]):
      konami_counter+=1
      
  if event.is_action_pressed(IMANOK_CODE[imanok_counter]):
    imanok_counter+=1
    if imanok_counter >= len(IMANOK_CODE):
      imanok_counter = 0
      quest_manager.quest_counter_progress(QuestGlobals.StatTrack.STAT_IMANOK_CODE)
  else:
    imanok_counter = 0
    if event.is_action_pressed(IMANOK_CODE[imanok_counter]):
      imanok_counter+=1
