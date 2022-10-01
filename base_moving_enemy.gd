extends CharacterBody2D
class_name BaseMovingEnemy

# I am sorry for this extremely stupid class hierarchy.
# Goodbye.

# Set this in the subclass.
# The superclass will take it and apply status modifiers before moving.
var desired_velocity: Vector2 = Vector2.ZERO

func _physics_process():
  super._physics_process()
          
  velocity = desired_velocity * time_left

  move_and_slide()
  
  # hit the player
  if _hurts_on_contact:
    for q in range(get_slide_collision_count()):
      var collision: KinematicCollision2D = get_slide_collision(q)
      var collider: Node2D = collision.get_collider()

      if collider.has_method("damage"):
        collider.damage(-1, - collider.position.direction_to(position))
