extends CharacterBody3D

@export var SPEED = 5.0

var target_velocity= Vector3.ZERO

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
			pass
		STATE.WALKING:
			var direction= Vector3.ZERO
			if Input.is_action_pressed("move_right"):
				direction.x += 1
			if Input.is_action_pressed("move_left"):
				direction.x -= 1
			if Input.is_action_pressed("move_forward"):
				direction.z -= 1
			if Input.is_action_pressed("move_back"):
				direction.z += 1
				
			if direction != Vector3.ZERO:
				direction= direction.normalized()
					
			target_velocity.x= direction.x * SPEED
			target_velocity.z= direction.z * SPEED
		STATE.RUNNING:
			pass
		STATE.CROUCHED:
			pass
		STATE.HIDING:
			pass
	move_and_slide()
