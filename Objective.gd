extends Label

@export var steps: float

func sleep(sec: float)->void:
	await get_tree().create_timer(sec).timeout

func text_appear() -> void:
	modulate.a = 1
	for i in range(get_total_character_count()+1):
		set_visible_characters(i)
		await sleep(maxf(0.02, randfn(0.1, 0.1)))

func text_vanish() -> void:
	for i in range(steps+1):
		modulate.a = 1.0 - (float(i) / steps)
		await sleep(0.02)
	modulate.a = 0
	set_visible_characters(0)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible_characters(0)
	
	
	# TEST sollten wir rausnehmen später
	while true:
		await show_objective("test test test test test test test test")
		await sleep(5)
		await hide_objective()
		await sleep(5)

func show_objective(txt: String) -> void:
	set_text(txt)
	await text_appear()
	
func hide_objective():
	await text_vanish()
	set_text("")
