extends Node2D

signal game_won
signal game_lost

@export var towers_to_win := 0
@export var towers_to_lose := 0


func _process(_delta: float) -> void:
	var destroyed_towers := get_tree().get_nodes_in_group("destroyed_tower")
	if destroyed_towers.size() >= towers_to_lose:
		print("lost")
		game_lost.emit()
		queue_free()
		
	var towers_on := get_tree().get_nodes_in_group("tower_on")
	if towers_on.size() >= towers_to_win:
		print("won")
		game_won.emit()
		queue_free()
