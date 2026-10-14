extends Marker3D

@export var vignette: TextureRect
@export var fade_speed: float = 1.2

@onready var detector: Area3D = $Detector

var inside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vignette.modulate.a = 0.0

func _physics_process(_delta: float) -> void:
	inside = false
	for zone: Area3D in get_tree().get_nodes_in_group("zones"):
		if zone.overlaps_area(detector):
			inside = true
			break
	print("zones: ", get_tree().get_nodes_in_group("zones").size(), " inside: ", inside)
	
func _process(delta: float) -> void:
	var target = 1.0 if inside else 0.0
	var weight = 1.0 - exp(-fade_speed * delta)
	vignette.modulate.a = lerpf(vignette.modulate.a, target, weight)
