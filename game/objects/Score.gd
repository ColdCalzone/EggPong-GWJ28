extends Control

var player_1_score : int = 0
var player_2_score : int = 0

onready var player_1_label = $Scores/Player1Score
onready var player_2_label = $Scores/Player2Score

func tick_score(player : int):
	if player == 1:
		player_1_score += 1
	elif player == 2:
		player_2_score += 1
	player_1_label.text = String(player_1_score)
	player_2_label.text = String(player_2_score)
