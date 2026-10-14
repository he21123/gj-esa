extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.dead.connect(on_dead)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	
func on_dead():
	GameState.ActualHP = GameState.MaxHP
	get_tree().call_deferred("change_scene_to_file", "res://Szenen/node_3d.tscn")
	
