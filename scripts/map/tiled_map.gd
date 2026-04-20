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
@export var debug_cableflow := true
@export var chunk_library: Array[PackedScene] = []
@export var map_size := Vector2i.ZERO
@export var towers_amount := 0
@export var starting_chunk: PackedScene

var generator := preload("res://scripts/map/procedural_generator.gd").new()
var merger := preload("res://scripts/map/chunk_merger.gd").new()
var flow_field := preload("res://scripts/map/flow_field.tres")
var cable_flowfield := preload("res://scripts/map/cable_flowfield.tres")
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
@onready var cable_flow_layer := $CableFlowFieldDebug


func _ready():
	debug_flow_layer.visible = debug_flow
	cable_flow_layer.visible = debug_cableflow
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
			world = generator.build_world(starting_chunk, chunk_library, map_size.x, map_size.y, towers_amount)
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
			print(towers)
			spawn_materials()
			free_world(world)
			spawn.queue_free()
			flow_field.setup(ground, wall, clutter)
			cable_flowfield.setup(ground, wall, clutter)
			#create_cableflowfield(towers)
	)
	

func spawn_towers(world: Array) -> Array:
	var candidates: Array[Vector2] = []
	for cell in spawn.get_used_cells():
		var atlas_coords: Vector2i = spawn.get_cell_atlas_coords(cell)
		if atlas_coords == null:
			continue
		
		if atlas_coords == TOWER_ATLAS:
			var world_pos: Vector2 = spawn.map_to_local(cell)
			candidates.append(world_pos)
	
	var chosen: Array[Vector2] = []
	chosen.append(candidates.pick_random())
	
	while chosen.size() < towers_amount and candidates.size() > 0:
		var best_pos: Vector2 = Vector2.ZERO
		var best_dist := -1.0
		
		for pos in candidates:
			var min_dist := INF
			for c in chosen:
				var d := pos.distance_to(c)
				if d < min_dist:
					min_dist = d
			if min_dist > best_dist:
				best_dist = min_dist
				best_pos = pos
		chosen.append(best_pos)
		candidates.erase(best_pos)
	
	var tower_scene := preload("res://scenes/entity/signal_tower.tscn")
	var towers = []
	
	for c in chosen:
		var tower: Node = tower_scene.instantiate()
		tower.global_position = c
		towers.append(tower)
		EntityManager.add_entity(tower)

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
			if chunk.spawn: chunk.spawn.free()

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
	

func create_cableflowfield(towers: Array) -> void:
	var destinations: Array[Vector2] = []
	for tower in towers:
		destinations.append(tower.global_position)
	
	cable_flowfield.created = false
	cable_flowfield.compute_cost_field(destinations)
	cable_flowfield.compute_flow_field()
	cable_flowfield.created = true
	
	if debug_cableflow:
		draw_cableflow_debug()


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


func draw_cableflow_debug() -> void:
	cable_flow_layer.clear()

	for x in cable_flowfield.size.x:
		for y in cable_flowfield.size.y:
			var dir: Vector2 = cable_flowfield.flow_field[x][y]
			if dir == Vector2.ZERO:
				continue

			var cell := Vector2i(x, y)
			var atlas_coord := direction_to_tile(dir)

			cable_flow_layer.set_cell(cell, 0, atlas_coord)


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
