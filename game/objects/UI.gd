extends CanvasLayer

onready var target = preload("res://objects/EggTarget.tscn")
onready var egg_sprite = preload("res://sprites/egg_insides.png")
onready var group_left = $Center/VSort/ScoreCenter/HSort/EggTargetsLeft
onready var left_count : int = 0
onready var right_count : int = 0
onready var maximum : int = 0
onready var left_text
onready var group_right = $Center/VSort/ScoreCenter/HSort/EggTargetsRight
onready var right_text

func toggle_visibility():
	for child in get_children():
		child.visible = !child.visible

func add_targets(count : int):
	if count <= 12:
		for x in range(count):
			group_left.add_child(target.instance())
			group_right.add_child(target.instance())
	else:
		group_left.add_child(target.instance())
		group_right.add_child(target.instance())
		maximum = count
		left_count = count
		right_count = count
		var text_left = Label.new()
		left_text = text_left
		text_left.set("custom_fonts/font", load("res://fonts/KarmaticArcade.tres"))
		group_left.add_child(text_left)
		text_left.text = "x" + String(left_count)
		var text_right = Label.new()
		right_text = text_right
		text_right.set("custom_fonts/font", load("res://fonts/KarmaticArcade.tres"))
		text_right.text = "x" + String(right_count)
		group_right.add_child(text_right)

func update_count(left : bool, value : int):
	if left:
		left_text.text = "x" + String(maximum - value)
	else:
		right_text.text = "x" + String(maximum - value)
