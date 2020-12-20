extends Node2D

onready var tween = $Tween
onready var sprite = $Sprite
onready var particles = $Particles2D
var waiting = true
var valid = true

func _ready():
	if OS.has_feature("web"):
		particles.emitting = false
		waiting = false

func zoooooooom(target_pos : Vector2):
	if valid:
		tween.remove(self, "position")
		tween.interpolate_property(self, "global_position", global_position, target_pos, 0.75, Tween.TRANS_CUBIC, Tween.EASE_IN)
		yield(get_tree().create_timer(1.0), "timeout")
		tween.start()
		yield(tween, "tween_all_completed")
		particles.emitting = false
	else:
		yield(get_tree().create_timer(0.1), "timeout")
		zoooooooom(target_pos)

func idle(target_pos : Vector2):
	tween.interpolate_property(self, "global_position", global_position, target_pos, 0.75, Tween.TRANS_CUBIC, Tween.EASE_IN)
	yield(get_tree().create_timer(1.0), "timeout")
	tween.start()
	yield(tween, "tween_all_completed")
	while waiting:
		valid = false
		tween.interpolate_property(self, "position", position, position + Vector2(0, 5), 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 1)
		tween.start()
		yield(tween, "tween_all_completed")
		valid = true
		tween.interpolate_property(self, "position", position, position - Vector2(0, 5), 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 2)
		tween.start()
		yield(tween, "tween_all_completed")
		yield(get_tree().create_timer(1), "timeout")
		valid = true
	
