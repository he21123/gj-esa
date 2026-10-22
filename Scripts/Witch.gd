extends TextureRect

var maus_inside=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation_degrees= lerp(rotation_degrees,-10.0,delta*10.0)
	pass
	


func _on_texture_rect_mouse_entered() -> void:
	pass # Replace with function body.


func _on_control_mouse_entered() -> void:
	pass # Replace with function body.
