extends CharacterBody3D

@export var player: CharacterBody3D
@onready var Nav_agent: NavigationAgent3D  = $Nav

var speed= 7.0


enum state { WAITING, ENTERING, IN, LEAVING}

@export var Speed: float = 4.0
@export var TimeOut: float = 30.0
@export var TimeIn: float = 10.0

@export var Position_Out: Vector3 = Vector3(20, 0, 0)
@export var Position_In: Vector3 = Vector3(0, 0, 0)

@onready var Wait_time: Timer = $Timer

var State: state= state.WAITING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	player= get_tree().get_nodes_in_group("Player")[0]
	
	global_position = Position_Out
	Wait_time.wait_time = TimeOut
	Wait_time.one_shot = true
	Wait_time.timeout.connect(_on_timer_espera_timeout)
	Wait_time.start()
	State= state.WAITING

func _physics_process(_delta: float) -> void:
	
	#-----STATE_MACHINE
	match State:
		state.WAITING:
			velocity=Vector3.ZERO
			move_and_slide()
		state.ENTERING:
			_go_to(Position_In)
			if global_position.distance_to(Position_In) <  0.5:
				State= state.IN
				Wait_time.wait_time=TimeIn
				Wait_time.start()
		state.IN:
			_follow()
		state.LEAVING:
			_go_to(Position_Out)
			if global_position.distance_to(Position_Out) < 0.5:
				State=state.WAITING
				Wait_time.wait_time=TimeOut
				Wait_time.start()
				

func  _go_to(objective:Vector3):
	Nav_agent.set_target_position(objective)
	if Nav_agent. is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	var next_location: Vector3 = Nav_agent.get_next_path_position()
	velocity= global_position.direction_to(next_location)*speed
	move_and_slide()
	
	look_at(player.global_position, Vector3.UP, true)
	rotation.x = 0
	
func _follow():
	Nav_agent.set_target_position(player.global_position)
	
	if Nav_agent.is_navigation_finished():
		return
	var next_location: Vector3= Nav_agent.get_next_path_position()
	velocity= global_position.direction_to(next_location)* speed
	move_and_slide()
	
	look_at(player.global_position, Vector3.UP, true)
	rotation.x = 0
	

func _on_timer_espera_timeout():
	if State == state.WAITING:
		State = state.ENTERING
	elif State == state.IN:
		State = state.LEAVING
