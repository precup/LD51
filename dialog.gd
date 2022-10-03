extends ColorRect

func start_dialog(dialog_text: Array[String]) -> void:
  for msg in dialog_text:
    msg = msg.replace("$", "\n")
    $label.text = msg
    
    var break_all = false
    
    for i in range(msg.length() + 1):
      $label.visible_characters = i
      
      for wait in range(3):
        await get_tree().process_frame
        if Input.is_action_just_pressed("shoot"):
          await get_tree().process_frame
          
          break_all = true
          break
      if break_all:
        break
    
    $label.visible_characters = msg.length()
  
    while true:
      await get_tree().process_frame
      
      if Input.is_action_just_pressed("shoot"):
        break
        
  visible = false
  get_tree().paused = false
  $label.text = ""
