extends Node2D


func _ready() -> void:
	EntityManager.entities = $Entities
	EntityManager.add_entity(preload("res://scenes/entity/actor/player.tscn").instantiate())
