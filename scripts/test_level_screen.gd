extends Node2D


func _ready() -> void:
	randomize()
	
	var swarm_bot_scene := preload("res://scenes/entity/actor/swarm_bot.tscn")
	for i in range(500):
		var swarm_bot = swarm_bot_scene.instantiate()
		swarm_bot.global_position = Vector2(randf_range(0, 5000), randf_range(0, 5000))
		EntityManager.add_entity(swarm_bot)
