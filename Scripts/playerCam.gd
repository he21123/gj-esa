extends Camera3D

@export var sens := 0.003
@export var crouch_height = 1.0
@export var crouch_speed = 10.0
@export var collision_shape: CollisionShape3D
@export var headroom: float
var capsule: CapsuleShape3D
var upLimit := -70
var downLimit := 70
var stand_height: float
var og_y: float
var og_cam_y: float
var pitch := 0.00

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
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		pitch -= event.relative.y * sens
		pitch = clamp(pitch, deg_to_rad(upLimit), deg_to_rad(downLimit))
		rotation.x = pitch
