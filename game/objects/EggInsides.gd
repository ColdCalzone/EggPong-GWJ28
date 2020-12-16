extends Node2D

onready var tween = $Tween
onready var sprite = $Sprite

onready var target_pos = Vector2(100, 100)

func _ready():
	tween.interpolate_property(self, "position", position, target_pos, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	yield(get_tree().create_timer(1.0), "timeout")
	tween.start()
