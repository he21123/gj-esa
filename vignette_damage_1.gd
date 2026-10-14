extends TextureRect

@export var Veins: TextureRect
@export var Flash1: TextureRect
@export var Flash2: TextureRect
@export var Flash3: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.lose_life.connect(on_lose_life)
	Veins.visible=false
	Flash1.modulate.a=0.0
	Flash2.modulate.a=0.0
	Flash3.modulate.a=0.0
	pass # Replace with function body.



func _process(delta: float) -> void:
	if GameState.ActualHP !=3:
		visible=true
		var puls = sin(Time.get_ticks_msec() * 0.005) * 0.5 + 0.5
		var base_intensity = 1.0 - (float(GameState.ActualHP) / GameState.MaxHP)
		modulate.a = base_intensity * (0.7 + 0.3 * puls)
		Veins.modulate.a = base_intensity * (0.7 + 0.3 * puls)
		if GameState.ActualHP !=2:
			Veins.visible= true
	else:
		visible= false
		
	Flash1.modulate.a= lerp(Flash1.modulate.a, 0.0 , delta * 3.0)
	Flash2.modulate.a= lerp(Flash2.modulate.a, 0.0 , delta * 3.0)
	Flash3.modulate.a= lerp(Flash3.modulate.a, 0.0 , delta * 3.0)
func on_lose_life():
	Flash1.modulate.a= 1.0
	Flash2.modulate.a= 1.0
	Flash3.modulate.a= 1.0
	
	print("lose life")
