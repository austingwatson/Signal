extends Node2D

const ARROW_UP = Vector2i(3, 0)
const ARROW_RIGHT = Vector2i(0, 0)
const ARROW_DOWN = Vector2i(1, 0)
const ARROW_LEFT = Vector2i(2, 0)

const ARROW_UP_LEFT = Vector2i(0, 1)
const ARROW_UP_RIGHT = Vector2i(1, 1)
const ARROW_DOWN_RIGHT = Vector2i(3, 1)
const ARROW_DOWN_LEFT = Vector2i(2, 1)

const TOWER_ATLAS := Vector2i(19, 11)
const METAL_ATLAS := Vector2i(17, 11)
const POWERCELL_ATLAS := Vector2i(18, 11)
const SWARM_ATLAS := Vector2i(20, 11)
const HEAVY_ATLAS := Vector2i(21, 11)

@export var debug_flow := true
@export var chunk_library: Array[PackedScene] = []
@export var map_size := Vector2i.ZERO
@export var towers_amount := 0

var generator := preload("res://scripts/map/procedural_generator.gd").new()
var merger := preload("res://scripts/map/chunk_merger.gd").new()
var flow_field := preload("res://scripts/map/flow_field.tres")
var world_generator_id := -1
var flow_field_id := -1
var towers := []

var world: Array
var merged_chunks := false

@onready var ground = $Ground
@onready var wall = $Wall
@onready var clutter = $Clutter
@onready var spawn := $Spawn
@onready var debug_flow_layer := $FlowFieldDebug


func _ready():
	debug_flow_layer.visible = debug_flow
	GlobalSignals.activate_tower.connect(_on_activate_tower)
	GlobalSignals.deactivate_tower.connect(_on_deactivate_tower)
	
	await get_tree().create_timer(0.5).timeout
	build_world()
	

func _process(_delta: float) -> void:
	if world_generator_id != -1 and WorkerThreadPool.is_task_completed(world_generator_id):
		WorkerThreadPool.wait_for_task_completion(world_generator_id)
		
		world_generator_id = -1
		if not merged_chunks:
			merged_chunks = true
			merge_chunks()
		
		
	if flow_field_id != -1 and WorkerThreadPool.is_task_completed(flow_field_id):
		WorkerThreadPool.wait_for_task_completion(flow_field_id)
		flow_field_id = -1
		
		if debug_flow:
			draw_flow_debug()
		GlobalSignals.call_flow_field_done()
			

func build_world() -> void:
	world_generator_id = WorkerThreadPool.add_task(
		func():
			world = generator.build_world(chunk_library, map_size.x, map_size.y, towers_amount)
	)
	
func merge_chunks() -> void:
	merger.setup(world, ground, wall, clutter, spawn)
	for y in range(world.size()):
		for x in range(world[y].size()):
			merger.merge_single_chunk(x, y)
			await get_tree().process_frame
	finish_loading()
	

func finish_loading() -> void:
	world_generator_id = WorkerThreadPool.add_task(
		func():
			var towers = spawn_towers(world)
			spawn_materials()
			free_world(world)
			spawn.queue_free()
			flow_field.setup(ground, wall, clutter)
	)
	

func spawn_towers(world: Array) -> Array:
	var tower_scene := preload("res://scenes/entity/signal_tower.tscn")
	var towers = []

	for y in range(world.size()):
		for x in range(world[y].size()):
			var chunk: Chunk = world[y][x]

			if chunk.is_goal_chunk:
				var tower = tower_scene.instantiate()
				var placed_tower = false
				
				if chunk.spawn != null:
					var cells := chunk.spawn.get_used_cells()
					for cell in cells:
						var atlas_coords := chunk.spawn.get_cell_atlas_coords(cell)
						if atlas_coords == null:
							continue
						
						if atlas_coords == TOWER_ATLAS:
							var pos := chunk.spawn.map_to_local(cell)
							tower.global_position = pos
							placed_tower = true
							break
				
				if not placed_tower:
					var chunk_size = chunk.get_chunk_pixel_size()
					tower.global_position = Vector2(
						x * chunk_size.x + chunk_size.x * 0.5,
						y * chunk_size.y + chunk_size.y * 0.5
					)

				towers.append(tower)
				EntityManager.call_deferred("add_entity", tower)

	return towers


func spawn_materials() -> void:
	var metal_scene := preload("res://scenes/entity/material/metal_pickup.tscn")
	var power_cell_scene := preload("res://scenes/entity/material/power_cell_pickup.tscn")
	var swarm_bot_scene := preload("res://scenes/entity/actor/swarm_bot.tscn")
	var heavy_bot_scene := preload("res://scenes/entity/actor/heavy_bot.tscn")

	var spawn_cells = spawn.get_used_cells()
	for cell in spawn_cells:
		var atlas_coords: Vector2i = spawn.get_cell_atlas_coords(cell)
		if atlas_coords == null:
			continue
			
		var entity = null
		match atlas_coords:
			METAL_ATLAS:
				entity = metal_scene.instantiate()
			POWERCELL_ATLAS:
				entity = power_cell_scene.instantiate()
			SWARM_ATLAS:
				entity = swarm_bot_scene.instantiate()
			HEAVY_ATLAS:
				entity = heavy_bot_scene.instantiate()
		
		if entity != null:
			var world_pos = spawn.map_to_local(cell)
			entity.global_position = world_pos
			EntityManager.add_entity(entity)


func free_world(world: Array) -> void:
	for y in range(world.size()):
		for x in range(world[y].size()):
			var chunk = world[y][x]

			if chunk.ground: chunk.ground.free()
			if chunk.wall: chunk.wall.free()
			if chunk.clutter: chunk.clutter.free()

			chunk.free()
			world[y][x] = null


func create_flowfield(towers: Array) -> void:
	var destinations: Array[Vector2] = []
	for tower in towers:
		destinations.append(tower.global_position)

	flow_field_id = WorkerThreadPool.add_task(
		func():
			flow_field.created = false
			flow_field.compute_cost_field(destinations)
			flow_field.compute_flow_field()
			for i in range(0):
				flow_field.smooth_flow_field()
			flow_field.created = true
	)


func draw_flow_debug() -> void:
	debug_flow_layer.clear()

	for x in flow_field.size.x:
		for y in flow_field.size.y:
			var dir: Vector2 = flow_field.flow_field[x][y]
			if dir == Vector2.ZERO:
				continue

			var cell := Vector2i(x, y)
			var atlas_coord := direction_to_tile(dir)

			debug_flow_layer.set_cell(cell, 0, atlas_coord)


# ---------------------------------------------------------
# Convert direction vector → tile ID
# Replace TILE_* with your actual tile IDs
# ---------------------------------------------------------
func direction_to_tile(dir: Vector2) -> Vector2i:
	var angle := dir.angle()

	if angle >= -PI * 7/8 and angle < -PI * 5/8:
		return ARROW_UP_LEFT
	elif angle >= -PI * 5/8 and angle < -PI * 3/8:
		return ARROW_UP
	elif angle >= -PI * 3/8 and angle < -PI * 1/8:
		return ARROW_UP_RIGHT
	elif angle >= -PI * 1/8 and angle < PI * 1/8:
		return ARROW_RIGHT
	elif angle >= PI * 1/8 and angle < PI * 3/8:
		return ARROW_DOWN_RIGHT
	elif angle >= PI * 3/8 and angle < PI * 5/8:
		return ARROW_DOWN
	elif angle >= PI * 5/8 and angle < PI * 7/8:
		return ARROW_DOWN_LEFT
	else:
		return ARROW_LEFT


func _on_activate_tower(tower) -> void:
	towers.append(tower)
	while flow_field_id != -1:
		await get_tree().create_timer(0.5).timeout
	create_flowfield(towers)
	

func _on_deactivate_tower(tower) -> void:
	towers.erase(tower)
	while flow_field_id != -1:
		await get_tree().create_timer(0.5).timeout
	create_flowfield(towers)
