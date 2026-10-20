extends TextureRect

@export var SfxOverButton: AudioStreamPlayer
@export var button: Button

var is_maus_over= false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.mouse_entered.connect(_on_area_2d_mouse_entered)
	button.mouse_exited.connect(_mouse_exited)
	button.pressed.connect(_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_maus_over == true:
		size= lerp(size,Vector2(357.0,119.0),1.5)
		rotation_degrees=lerp(rotation_degrees,-3.0,delta*10)
	else:
		size= lerp(size,Vector2(339.0,111.0),1.5)
		rotation_degrees=lerp(rotation_degrees,0.0,delta*5)
	pass


func _pressed():
	get_tree().quit()

func _on_area_2d_mouse_entered() -> void:
	print("ssss")
	SfxOverButton.play()
	is_maus_over=true
	pass # Replace with function body.
	
func _mouse_exited():
	print("aaaa")
	is_maus_over=false
	pass
