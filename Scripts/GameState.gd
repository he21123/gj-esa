extends Node

@export var MaxHP: int=3
var ActualHP: int=3
var Invencibility: bool= false
var Invencibility_time: float= 1.5 

signal dead
signal actual_HP
signal lose_life

func take_damage():
	if Invencibility != true:
		lose_life.emit()
		ActualHP-=1
		Invencibility=true
		await get_tree().create_timer(Invencibility_time).timeout
		Invencibility=false
	if ActualHP == 0:
		dead.emit()
	
	
