extends CharacterBody3D

@export var SPEED = 5.0
@export var camera: Camera3D
@export var decel := 25.0
var target_velocity= Vector3.ZERO
# Moglichen "Sates"
enum STATE {
	IDLE,
	WALKING,
	RUNNING,
	CROUCHED,
	HIDING
}
var speed = SPEED

var Current_State: STATE = STATE.IDLE
var frozen: bool = false

func _enemy_start_chase(enemy: Node3D) -> void:
	frozen = true
	camera.startle(enemy)

func _enemy_chase_over() -> void:
	frozen = false
	camera.unstartle()

func check_state():
	#Die state ändern
	var moving = (
		Input.is_action_pressed("move_right")
		or Input.is_action_pressed("move_left") 
		or Input.is_action_pressed("move_back") 
		or Input.is_action_pressed("move_forward")
	)
	
	if frozen:
		Current_State = STATE.IDLE
	elif Input.is_action_pressed("crouching"):
		Current_State = STATE.CROUCHED
	elif moving and Input.is_action_pressed("running"):
		Current_State = STATE.RUNNING
	elif moving:
		Current_State = STATE.WALKING
	
	else:
		Current_State = STATE.IDLE

func _physics_process(delta: float) -> void:
	# update state every tick
	check_state()
	
	match Current_State:
		STATE.IDLE:
			#Die charakter Beweg sich nicht
			velocity.x= 0
			velocity.z= 0
			
		STATE.WALKING, STATE.RUNNING, STATE.CROUCHED:
			#Code für die character Bewegung
			if not is_on_floor():
				velocity += get_gravity() * delta
				
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var input_vector := Vector3(input_dir.x, 0, input_dir.y)
			var direction := camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
			direction.y = 0
			direction = direction.normalized()
			
			speed = SPEED
			
			if Current_State == STATE.RUNNING:
				speed *= 1.5
			elif Current_State == STATE.CROUCHED:
				speed *= 0.6
			
			if input_vector.length() > 0.0:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, decel * delta)
				velocity.z = move_toward(velocity.z, 0, decel * delta)
			
		STATE.HIDING:
			pass
	#velocity = target_velocity// Das muss hier bleiben, nicht anfassen
	move_and_slide()
	

func _on_dame_area_body_entered(_body: Node3D) -> void:
	GameState.take_damage()
	
