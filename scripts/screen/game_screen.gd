extends Node2D

@export var start_dialogue: Dialogue
@export var win_dialogue: Dialogue
@export var lose_dialogue: Dialogue
@onready var dialogue_controller := $HUD/DialogueController


func _ready() -> void:
	randomize()
	EntityManager.entities = $Entities


func _on_start_cutscene_cutscene_done() -> void:
	dialogue_controller.start(start_dialogue)


func _on_win_lose_conditions_game_lost() -> void:
	dialogue_controller.start(win_dialogue)


func _on_win_lose_conditions_game_won() -> void:
	dialogue_controller.start(lose_dialogue)
