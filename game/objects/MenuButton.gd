extends TextureButton

onready var tween = $Tween
onready var sprite = $Sprite
onready var fade = $Fade
onready var label = $Center/Label
export var slug = "play"
export var text = "play"

signal menu_button_clicked(slug)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = text
	connect("button_down", self, "transition_event")

func transition_event():
	for button in get_tree().get_nodes_in_group("menu_button"):
		button.disabled = true
	tween.interpolate_property(sprite, "frame", sprite.frame, sprite.hframes - 1, 0.3)
	# had to hardcode the window size here, it wasn't scaling when fullscreen, instead just popping into fullscreen
	# hardcoded 😬😬😬😬😬😬😬:I
	if slug != "res" and slug != "prev" and slug != "next":
		tween.interpolate_property(fade, "rect_scale", Vector2(0, 0), ((Vector2(640, 360) * 2.1) / fade.rect_size) * 1.5, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
		tween.interpolate_property(fade, "color", fade.color, Color(0, 0, 0, 0) + Color(0, 0, 0, 1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
		# This whole dealy is kind of bodged, but it basically makes buttons above itself fade like those below it.
		# if controls had Z-indexes this wouldn't've been necessary but whaddya gonna do?
		for button in get_tree().get_nodes_in_group("menu_button"):
			if button.is_greater_than(self):
				tween.interpolate_property(button, "modulate", Color(1, 1, 1, 1), Color(0, 0, 0, 1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("menu_button_clicked", slug)
	if slug == "prev" or slug == "next":
		tween.interpolate_property(sprite, "frame", sprite.frame, 0, 0.3)
		tween.start()
		yield(tween, "tween_all_completed")
