extends Node2D

@export var chunk_library: Array[PackedScene] = []
var generator := preload("res://scripts/map/procedural_generator.gd").new()
var merger := preload("res://scripts/map/chunk_merger.gd").new()
@onready var ground = $Ground
@onready var wall = $Wall
@onready var clutter = $Clutter

func _ready():
	var world = generator.build_world(chunk_library, 5, 5, 2)
	merger.merge_chunks(world, ground, wall, clutter)
	spawn_towers(world)
	free_world(world)
	

func spawn_towers(world: Array) -> void:
	var tower_scene := preload("res://scenes/entity/signal_tower.tscn")
	
	for y in range(world.size()):
		for x in range(world[y].size()):
			var chunk: Chunk = world[y][x]
			
			if chunk.is_goal_chunk:
				var tower = tower_scene.instantiate()
				var chunk_size = chunk.get_chunk_pixel_size()
				tower.global_position = Vector2(
					x * chunk_size.x + chunk_size.x * 0.5, 
					y * chunk_size.y + chunk_size.y * 0.5
					)
				EntityManager.add_child(tower)


func free_world(world: Array) -> void:
	for y in range(world.size()):
		for x in range(world[y].size()):
			var chunk = world[y][x]
			if chunk.ground: chunk.ground.free()
			if chunk.wall: chunk.wall.free()
			if chunk.clutter: chunk.clutter.free()
			chunk.free()
			
			world[y][x] = null
