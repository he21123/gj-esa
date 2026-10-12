extends Label

func sleep(sec: float)->void:
	await get_tree().create_timer(sec).timeout

func text_appear() -> void:
	for i in range(text.length()+1):
		set_visible_characters(i)
		await sleep(randfn(0.1, 0.1))

func text_vanish() -> void:
	for i in range(51):
		modulate.a = 1.0 - (float(i) / 50.0)
		await sleep(0.02)
	modulate.a = 0
	set_visible_characters(0)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible_characters(0)
	set_text("test test test test test test test")
	while true:
		await text_appear()
		await sleep(5)
		await text_vanish()
		await sleep(5)
