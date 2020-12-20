extends Node

var goal : int = 11 setget set_goal, get_goal
var singleplayer : bool = true setget set_singleplayer, get_singleplayer

func set_goal(value : int):
	goal = value
	
func get_goal():
	return goal

func set_singleplayer(value : bool):
	singleplayer = value
	
func get_singleplayer():
	return singleplayer
