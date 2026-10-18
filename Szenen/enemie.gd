extends CharacterBody3D

@export var player: CharacterBody3D
@onready var Nav_agent: NavigationAgent3D  = $Nav

var speed= 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	player= get_tree().get_nodes_in_group("Player")[0]

func _physics_process(_delta: float) -> void:
	Nav_agent.set_target_position(player.global_position)
	
	if Nav_agent.is_navigation_finished():
		return
	
	var current_location:= global_transform.origin
	var next_location: Vector3= Nav_agent.get_next_path_position()
	velocity= global_position.direction_to(next_location)* speed
	#var new_velocity= (next_location - current_location).normalized() * speed
	#
	#velocity= new_velocity
	move_and_slide()
	
	look_at(player.global_position, Vector3.UP, true)
	rotation.x = 0

#func _update_target_location(target_location):
	#Nav_agent.set_target_location(target_location)
