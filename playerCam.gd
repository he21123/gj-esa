extends Camera3D

@export var sens := 0.003
var upLimit := -70
var downLimit := 70

var pitch := 0.00

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		pitch -= event.relative.y * sens
		pitch = clamp(pitch, deg_to_rad(upLimit), deg_to_rad(downLimit))
		rotation.x = pitch
