extends RayCast2D

var tick = 0
var last_hit = 0

func _ready():
  var beam_particles: GPUParticles2D = $"../beam_particles"
  
  pulse()
  sweep_radial()

func pulse():
  var tween = create_tween()
  var line: Line2D = $"../line"
  
  while true:
    for new_width in range(800, 1000, 1):
      line.width = 10 + float(new_width) / 70.0
      
      await get_tree().process_frame
    
    for new_width in range(1000, 800, -1):
      line.width = 10 + float(new_width) / 70.0
      
      await get_tree().process_frame

func sweep_radial():
  var line: Line2D = $"../line"
  
  while true:
    for x in range(3600):
      var direction = Vector2(cos(deg_to_rad(float(x) / 10.0)), sin(deg_to_rad(float(x) / 10.0))).normalized()
      
      target_position = direction * 5000
      
      await get_tree().process_frame

@onready var hitsprite = preload("res://hitsprite.tscn")

func _physics_process(delta): 
  tick += 1
  
  var player = $"/root/root/references".get_player()
  var cast_point = target_position
  force_raycast_update()
  
  if is_colliding():
    cast_point = to_local(get_collision_point())

  var line: Line2D = $"../line"
  line.set_point_position(0, position)
  line.set_point_position(1, cast_point)
  
  var collision_particles: GPUParticles2D = $"../collision_particles"
  
  if is_colliding():
    if get_collider() == player:
      if tick > last_hit + 100:
        player.damage(-1, (player.global_position - global_position).normalized())
      
        var instance = hitsprite.instantiate()
        get_tree().root.add_child(instance)
        instance.global_position = get_collision_point()
        last_hit = tick
    
    collision_particles.visible = true
    collision_particles.global_rotation = get_collision_normal().angle()
    collision_particles.position = to_local(get_collision_point())
  else:
    collision_particles.visible = false
  
  var beam_particles: GPUParticles2D = $"../beam_particles"
  beam_particles.position = cast_point * 0.5
  var ppm: ParticleProcessMaterial = beam_particles.process_material
  ppm.emission_box_extents.x = cast_point.length() * 0.5
