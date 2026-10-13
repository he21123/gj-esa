extends CharacterBody3D

@export var SPEED = 5.0
@export var camera: Camera3D
var target_velocity= Vector3.ZERO
# Moglichen "Sates"
enum STATE {
	IDLE,
	WALKING,
	RUNNING,
	CROUCHED,
	HIDING
}

var Current_State: STATE = STATE.IDLE

func _physics_process(delta: float) -> void:
	match Current_State:
		STATE.IDLE:
			#Die charakter Beweg sich nicht
			velocity.x= 0
			velocity.z= 0
			#Die state ändern
			if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_forward"):
				Current_State = STATE.WALKING
				print("state change walking")
			
		STATE.WALKING:
			#Code für die character Bewegung
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var input_vector := Vector3(input_dir.x, 0, input_dir.y)
			var direction := camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
			direction.y = 0
			direction = direction.normalized()
			
			if input_vector.length() > 0.0:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
			if not Input.is_action_just_released("move_back") or not Input.is_action_just_released("move_forward") or not Input.is_action_just_released("move_left") or not Input.is_action_pressed("move_right"): 
				Current_State=STATE.IDLE
				print("state change idle")
		STATE.RUNNING:
			pass
		STATE.CROUCHED:
			pass
		STATE.HIDING:
			pass
	#velocity = target_velocity// Das muss hier bleiben, nicht anfassen
	move_and_slide()
