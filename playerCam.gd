extends Camera3D

@export var sens := 0.003
@export var stand_height = 0.5
@export var crouch_height = 0.2
@export var crouch_speed = 10.0
var upLimit := -70
var downLimit := 70

var pitch := 0.00

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouching"):
		position.y = move_toward(position.y, crouch_height, crouch_speed*delta)
	else:
		position.y = move_toward(position.y, stand_height, crouch_speed*delta)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		pitch -= event.relative.y * sens
		pitch = clamp(pitch, deg_to_rad(upLimit), deg_to_rad(downLimit))
		rotation.x = pitch
