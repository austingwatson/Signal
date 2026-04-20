extends Node2D


func _ready() -> void:
	randomize()
	
	EntityManager.entities = $Entities
	EntityManager.add_entity(preload("res://scenes/entity/actor/player.tscn").instantiate())
	
	set_process(false)
		

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("add_swarm"):
		var swarm_bot_scene := preload("res://scenes/entity/actor/swarm_bot.tscn")
		for i in range(50):
			var swarm_bot = swarm_bot_scene.instantiate()
			swarm_bot.global_position = Vector2(randf_range(50, 2500), randf_range(50, 2500))
			EntityManager.add_enemy(swarm_bot)


func _process(_delta: float) -> void:
	print(get_tree().get_nodes_in_group("enemy").size())
