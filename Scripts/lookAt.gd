extends CharacterBody3D

@export var player: CharacterBody3D

var speed= 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	look_at(player.global_position, Vector3.UP, true)
	rotation.x = 0
