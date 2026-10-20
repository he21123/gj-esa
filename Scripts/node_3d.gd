extends Node3D
@export var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.dead.connect(on_dead)
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	get_tree().call_group("enemies","_update_target_location", player.global_transform.origin)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_dead():
	GameState.ActualHP = GameState.MaxHP
	get_tree().call_deferred("change_scene_to_file", "res://Szenen/node_3d.tscn")
	
