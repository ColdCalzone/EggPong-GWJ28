extends Node2D

onready var left = $Left
onready var right = $Right
onready var middle_dark : Array = [$MiddleDark, $MiddleDark2, $MiddleDark3]
onready var middle = $MiddleLight
onready var tween = $Tween

signal transition_finished

func _ready():
	for middle_darks in middle_dark:
		tween.interpolate_property(middle_darks, "visible", true, false, 0.6)
	tween.interpolate_property(middle, "visible", true, false, 0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	tween.interpolate_property(left, "position", left.position, left.position - Vector2(364, 0), 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.6)
	tween.interpolate_property(right, "position", right.position, right.position + Vector2(387, 0), 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.6)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("transition_finished")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
