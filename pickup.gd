extends RayCast3D

var selected_obj: RigidBody3D = null
var held_obj: RigidBody3D = null

var high_obj: RigidBody3D = null
var og_albedo: Color
var high_mat: ShaderMaterial

@export var PULL_STRENGTH: float
@export var PULL_DAMP: float
@export var MAX_ACCEL: float
@export var hold_point: Marker3D

var prev_hold_pos: Vector3
var hold_point_vel: Vector3 = Vector3.ZERO

func set_high(obj: RigidBody3D):
	# ich hätte das dokumentieren müssen als ich noch wusste was ich hier gemacht hab 😭
	
	if high_obj != null and is_instance_valid(high_obj):
		if high_mat:
			high_mat.set_shader_parameter("albedo_color", og_albedo)
	
	high_obj = obj
	high_mat = null
	
	if high_obj == null:
		return
	
	var mesh: MeshInstance3D = high_obj.get_node_or_null("MeshInstance3D")
	if mesh == null:
		return
	
	var mat: ShaderMaterial = mesh.get_active_material(0)
	if mat == null:
		return
	
	high_mat = mat.duplicate() as ShaderMaterial
	mesh.set_surface_override_material(0, high_mat)
	
	og_albedo = high_mat.get_shader_parameter("albedo_color")
	
	var high_color := og_albedo.lerp(Color.WHITE, 0.2)
	high_mat.set_shader_parameter("albedo_color", high_color)

func _ready() -> void:
	add_exception(get_parent().get_parent())
	prev_hold_pos = hold_point.global_position

func _physics_process(delta: float) -> void:
	
	hold_point_vel = (hold_point.global_position - prev_hold_pos) / delta
	prev_hold_pos = hold_point.global_position
	
	selected_obj = null
	
	if is_colliding():
		var hit_obj = get_collider()
		if hit_obj is RigidBody3D:
			selected_obj = hit_obj
	
	if Input.is_action_just_pressed("pickup"):
		if held_obj == null and selected_obj != null:
			held_obj = selected_obj
		elif held_obj:
			held_obj.sleeping = false
			held_obj = null
	
	if held_obj != null:
		if not is_instance_valid(held_obj):
			held_obj = null
			return
		
		var pos_error: Vector3 = (hold_point.global_position - held_obj.global_position)
		var vel_error: Vector3 = (hold_point_vel - held_obj.linear_velocity)
		
		var accel: Vector3 = (pos_error * PULL_STRENGTH
			+ vel_error * PULL_DAMP
			- held_obj.get_gravity()
		)
		
		accel = accel.limit_length(MAX_ACCEL)
		
		held_obj.apply_central_force(accel * held_obj.mass)
	
	if selected_obj != high_obj:
		set_high(selected_obj)
		
