extends Label

@export var enemy: CharacterBody3D

func _ready() -> void:
	set_text("")

func _process(_delta: float) -> void:
	if enemy == null or not enemy.chase_enabled:
		visible = false
		set_text("")
		return
	visible = true
	if enemy.State == enemy.state.WAITING:
		var seconds: int = ceili(enemy.Wait_time.time_left)
		set_text("%02d:%02d" % [int(seconds / 60.0), seconds % 60])
	else:
		set_text("")
