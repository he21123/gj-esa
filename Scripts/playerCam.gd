extends Camera3D

@export var sens := 0.003
@export var crouch_height = 1.0
@export var crouch_speed = 10.0
@export var collision_shape: CollisionShape3D
@export var headroom: float
@export var turn_speed: float = 2.0
var capsule: CapsuleShape3D
var upLimit := -70
var downLimit := 70
var stand_height: float
var og_y: float
var og_cam_y: float
var pitch := 0.00
var turn_enemy: Node3D
var tracking: bool = false
var turned_around: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	capsule = collision_shape.shape.duplicate()
	collision_shape.shape = capsule
	stand_height = capsule.height
	og_y = collision_shape.position.y
	og_cam_y = position.y

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = from + Vector3.UP * headroom
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_parent().get_rid()]
	var result = space_state.intersect_ray(query)
	
	if Input.is_action_pressed("crouching"):
		capsule.height = move_toward(capsule.height, crouch_height, crouch_speed*delta)
	else:
		if result.is_empty():
			capsule.height = move_toward(capsule.height, stand_height, crouch_speed*delta)
	
	var bottom = og_y - stand_height / 2.0
	collision_shape.position.y = bottom + capsule.height / 2.0
	position.y = bottom + (og_cam_y - bottom) * capsule.height / stand_height
	
	if tracking:
		_turn_to_enemy(delta)

func startle(enemy: Node3D) -> void:
	turn_enemy = enemy
	tracking = true
	turned_around = false

func unstartle() -> void:
	tracking = false

func _turn_to_enemy(delta: float) -> void:
	var dir: Vector3 = (turn_enemy.global_position - global_position).normalized()
	var target_yaw = atan2(-dir.x, -dir.z)
	var yaw_left = wrapf(target_yaw - rotation.y, -PI, PI)
	rotate_y(clampf(yaw_left, -turn_speed * delta, turn_speed * delta))
	var target_pitch = clampf(asin(clampf(dir.y, -1.0, 1.0)), deg_to_rad(upLimit), deg_to_rad(downLimit))
	pitch += clampf(target_pitch - pitch, -turn_speed * delta, turn_speed * delta)
	rotation.x = pitch
	if not turned_around and absf(yaw_left) <= turn_speed * delta and absf(target_pitch - pitch) <= turn_speed * delta:
		turned_around = true
		get_tree().call_group("Enemies", "_startle_done")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not tracking:
		rotate_y(-event.relative.x * sens)
		pitch -= event.relative.y * sens
		pitch = clamp(pitch, deg_to_rad(upLimit), deg_to_rad(downLimit))
		rotation.x = pitch
