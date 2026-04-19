extends Node2D


func _ready() -> void:
	randomize()
	
	var swarm_bot_scene := preload("res://scenes/entity/actor/swarm_bot.tscn")
	for i in range(10):
		var swarm_bot = swarm_bot_scene.instantiate()
		swarm_bot.global_position = Vector2(randf_range(50, 1000), randf_range(50, 1000))
		EntityManager.add_enemy(swarm_bot)
