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
@export var Position_Lost: Vector3 = Vector3(0, 0, 0)

@export var arrive_distance: float = 1.5

@export_group("Periodic Chase")
@export var chase_enabled: bool = true

@export_group("Sight")
@export var view_range: float = 12.0
@export var view_angle: float = 80.0
@export var eye_height: float = 0.5
@export var player_target_height: float = 0.5

@export_group("Viewcone Visual")
@export var show_viewcone: bool = true
@export var cone_color: Color = Color(0.9, 0.05, 0.05, 0.35)
@export var cone_tex_size: int = 128
@export var cone_soft: float = 0.1
@export var cone_decal_y: float = -1.0
@export var cone_height: float = 6.0
@export var cone_forward_offset: float = 0.35
@export var cone_fade: float = 0.6

@onready var Wait_time: Timer = $Timer

var State: state= state.WAITING
var hide_point: Marker3D
var startle_turn: bool = false
var alerted: bool = false
var heading_to_lost: bool = false

var _cone: Decal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	player= get_tree().get_nodes_in_group("Player")[0]
	hide_point= player.get_node_or_null("Camera3D/HidePoint")
	
	global_position = Position_Out
	Wait_time.wait_time = TimeOut
	Wait_time.one_shot = true
	Wait_time.timeout.connect(_on_timer_espera_timeout)
	if chase_enabled:
		Wait_time.start()
	State= state.WAITING
	_setup_viewcone()

func _physics_process(_delta: float) -> void:
	
	#-----STATE_MACHINE
	match State:
		state.WAITING:
			_show_viewcone(false)
			velocity=Vector3.ZERO
			move_and_slide()
		state.ENTERING:
			_check_player_sight()
			_show_viewcone(true)
			if startle_turn:
				velocity=Vector3.ZERO
				move_and_slide()
			else:
				_go_to(Position_In)
				if _arrived_at(Position_In):
					State= state.IN
					heading_to_lost= false
					Wait_time.wait_time=TimeIn
					Wait_time.start()
		state.IN:
			_check_player_sight()
			_show_viewcone(true)
			if startle_turn:
				velocity=Vector3.ZERO
				move_and_slide()
			elif alerted:
				_follow()
			elif heading_to_lost:
				_go_to(Position_Lost)
				if _arrived_at(Position_Lost):
					State= state.LEAVING
			else:
				velocity=Vector3.ZERO
				move_and_slide()
				_face_player()
		state.LEAVING:
			_show_viewcone(false)
			_go_to(Position_Out)
			if _arrived_at(Position_Out):
				State=state.WAITING
				alerted= false
				heading_to_lost= false
				Wait_time.wait_time=TimeOut
				Wait_time.start()
				get_tree().call_group("Player", "_enemy_chase_over")
				

func  _go_to(objective:Vector3):
	Nav_agent.set_target_position(objective)
	if Nav_agent. is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	var next_location: Vector3 = Nav_agent.get_next_path_position()
	velocity= global_position.direction_to(next_location)*speed
	move_and_slide()
	
	_face_player()
	
func _follow():
	Nav_agent.set_target_position(player.global_position)
	
	if Nav_agent.is_navigation_finished():
		return
	var next_location: Vector3= Nav_agent.get_next_path_position()
	velocity= global_position.direction_to(next_location)* speed
	move_and_slide()
	
	_face_player()
	

func _face_player() -> void:
	look_at(player.global_position, Vector3.UP, true)
	rotation.x = 0


func _on_timer_espera_timeout():
	if not chase_enabled:
		return
	if State == state.WAITING:
		State = state.ENTERING
		alerted = false
	elif State == state.IN:
		if alerted:
			State = state.LEAVING
		else:
			heading_to_lost = true

func _startle_done() -> void:
	startle_turn = false

func _is_player_hidden() -> bool:
	if hide_point == null:
		return false
	return hide_point.inside

func _flat_distance_to(objective: Vector3) -> float:
	return Vector2(global_position.x, global_position.z).distance_to(
			Vector2(objective.x, objective.z))

func _arrived_at(objective: Vector3) -> bool:
	return Nav_agent.is_navigation_finished() \
			and _flat_distance_to(objective) < arrive_distance

func _check_player_sight() -> void:
	if alerted or startle_turn or not chase_enabled:
		return
	if not _can_see_player():
		return
	alerted = true
	State = state.IN
	Wait_time.stop()
	Wait_time.wait_time = TimeIn
	Wait_time.start()
	startle_turn = true
	get_tree().call_group("Player", "_enemy_start_chase", self)

func _can_see_player() -> bool:
	if player == null:
		return false
	if _is_player_hidden():
		return false
	var flat_dir := Vector2(player.global_position.x - global_position.x,
			player.global_position.z - global_position.z)
	if flat_dir.length() > view_range:
		return false
	if flat_dir == Vector2.ZERO:
		return true
	var forward := global_transform.basis.z
	var flat_forward := Vector2(forward.x, forward.z)
	if flat_forward == Vector2.ZERO:
		return true
	if abs(rad_to_deg(flat_forward.angle_to(flat_dir))) > view_angle * 0.5:
		return false
	var from: Vector3 = global_position + Vector3.UP * eye_height
	var to: Vector3 = player.global_position + Vector3.UP * player_target_height
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.get("collider") == player

func _setup_viewcone() -> void:
	_cone = Decal.new()
	_cone.name = "ViewCone"
	_cone.size = Vector3(_cone_width(), cone_height, view_range)
	_cone.position = Vector3(0.0, cone_decal_y, view_range * 0.5 + cone_forward_offset)
	_cone.upper_fade = cone_fade
	_cone.lower_fade = cone_fade
	_cone.texture_albedo = _make_cone_texture()
	add_child(_cone)
	_cone.visible = false

func _cone_width() -> float:
	return 2.0 * view_range * tan(deg_to_rad(view_angle) * 0.5)

func _make_cone_texture() -> ImageTexture:
	var n := maxi(cone_tex_size, 8)
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in n:
		var v := float(y) / float(n - 1)
		var half_w := maxf(v * 0.5, 0.0001)
		for x in n:
			var u := float(x) / float(n - 1)
			var ang := absf(u - 0.5) / half_w
			var a := 1.0 - smoothstep(1.0 - cone_soft, 1.0, ang)
			a *= smoothstep(0.0, 0.04, v)
			a *= 1.0 - smoothstep(0.7, 1.0, v)
			img.set_pixel(x, y, Color(cone_color.r, cone_color.g, cone_color.b,
					cone_color.a * clampf(a, 0.0, 1.0)))
	return ImageTexture.create_from_image(img)

func _show_viewcone(hunting: bool) -> void:
	if _cone == null:
		return
	_cone.visible = hunting and show_viewcone and chase_enabled and not alerted
