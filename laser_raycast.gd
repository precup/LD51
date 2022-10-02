extends RayCast2D

func _ready():
  var beam_particles: GPUParticles2D = $"../beam_particles"
  # beam_particles.visible = false
  
  
  pulse()
  sweep()

func pulse():
  var tween = create_tween()
  var line: Line2D = $"../line"
  
  while true:
    for new_width in range(800, 1000, 1):
      line.width = float(new_width) / 70.0
      
      await get_tree().process_frame
    
    for new_width in range(1000, 800, -1):
      line.width = float(new_width) / 70.0
      
      await get_tree().process_frame

func sweep():
  var initial = Vector2(1000, -300)
  var line: Line2D = $"../line"
  
  while true:
    for y in range(0, 600, 1):
      target_position = initial + Vector2(0, y)
      
      await get_tree().process_frame
    
    for y in range(600, 0, -1):
      target_position = initial + Vector2(0, y)
      
      await get_tree().process_frame

func _physics_process(delta):  
  var cast_point = target_position
  force_raycast_update()
  
  if is_colliding():
    cast_point = to_local(get_collision_point())

  var line: Line2D = $"../line"
  line.set_point_position(0, position)
  line.set_point_position(1, cast_point)
  
  var collision_particles: GPUParticles2D = $"../collision_particles"
  collision_particles.global_rotation = get_collision_normal().angle()
  collision_particles.position = to_local(get_collision_point())
  
  var beam_particles: GPUParticles2D = $"../beam_particles"
  beam_particles.position = cast_point * 0.5
  var ppm: ParticleProcessMaterial = beam_particles.process_material
  ppm.emission_box_extents.x = cast_point.length() * 0.5
