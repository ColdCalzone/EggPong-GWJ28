extends TextureButton

onready var tween = $Tween
onready var sprite = $Sprite
onready var fade = $Fade

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("button_down", self, "transition_event")

func transition_event():
	tween.interpolate_property(sprite, "frame", sprite.frame, sprite.hframes - 1, 0.3)
	tween.interpolate_property(fade, "rect_scale", Vector2(0, 0), (OS.window_size / fade.rect_size) * 1.5, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.1)
	tween.interpolate_property(fade, "color", fade.color, Color(0, 0, 0, 0) + Color(0, 0, 0, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.3)
	tween.start()
