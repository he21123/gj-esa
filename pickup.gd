extends RayCast3D

var selected_obj: RigidBody3D = null
var held_obj: RigidBody3D = null

@export var PULL_STRENGTH: float
@export var PULL_DAMP: float
@export var MAX_ACCEL: float
@export var hold_point: Marker3D

var prev_hold_pos: Vector3
var hold_point_vel: Vector3 = Vector3.ZERO

func dist(a:float, b:float) -> float:
	var distance = 0
	if a > b:
		distance = a-b
	else:
		distance = b-a
	return distance

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
