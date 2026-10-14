extends Node

@export var MaxHP: int=3
var ActualHP: int
var Invencibility: bool= false
var Invencibility_time: float= 1.5 

signal dead
signal actual_HP
signal lose_life

func take_damage():
	if Invencibility == false:
		ActualHP-=1
		lose_life.emit()
		Invencibility=true
		await get_tree().create_timer(Invencibility_time).timeout
	if ActualHP <= 0:
		dead.emit()
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
