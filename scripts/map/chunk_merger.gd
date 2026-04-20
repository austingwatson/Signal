extends Node

const TOWER_ATLAS := Vector2i(19, 11)

var world: Array
var final_ground: TileMapLayer
var final_wall: TileMapLayer
var final_clutter: TileMapLayer
var final_spawn: TileMapLayer


func setup(world: Array, final_ground: TileMapLayer, final_wall: TileMapLayer, final_clutter: TileMapLayer, final_spawn: TileMapLayer) -> void:
	self.world = world
	self.final_ground = final_ground
	self.final_wall = final_wall
	self.final_clutter = final_clutter
	self.final_spawn = final_spawn


func merge_single_chunk(x: int, y: int) -> void:
	var chunk = world[y][x]
	if chunk == null:
		return
		
	var offset = compute_chunk_offset(world, x, y)
	merge_layer(chunk.ground, final_ground, offset)
	merge_layer(chunk.wall, final_wall, offset)
	merge_layer(chunk.clutter, final_clutter, offset)
	merge_spawn_layer(chunk.spawn, final_spawn, offset, chunk.spawn_chance)
	

func merge_chunks(world: Array, final_ground: TileMapLayer, final_wall: TileMapLayer, final_clutter: TileMapLayer, final_spawn: TileMapLayer):
	for y in range(world.size()):
		for x in range(world[y].size()):
			var chunk = world[y][x]
			if chunk == null:
				continue

			var offset = compute_chunk_offset(world, x, y)
			merge_layer(chunk.ground, final_ground, offset)
			merge_layer(chunk.wall, final_wall, offset)
			merge_layer(chunk.clutter, final_clutter, offset)
			merge_spawn_layer(chunk.spawn, final_spawn, offset, chunk.spawn_chance)


func merge_layer(src: TileMapLayer, dst: TileMapLayer, offset: Vector2i):
	if src == null:
		return

	for cell in src.get_used_cells():
		var id = src.get_cell_source_id(cell)
		var atlas = src.get_cell_atlas_coords(cell)
		var alt = src.get_cell_alternative_tile(cell)

		dst.set_cell(cell + offset, id, atlas, alt)
		

func merge_spawn_layer(src: TileMapLayer, dst: TileMapLayer, offset: Vector2i, spawn_chance: float):
	if src == null:
		return
	
	for cell in src.get_used_cells():	
		var atlas = src.get_cell_atlas_coords(cell)
		
		if atlas == TOWER_ATLAS:
			pass
		elif randf() >= spawn_chance:
			continue
		
		var id = src.get_cell_source_id(cell)
		var alt = src.get_cell_alternative_tile(cell)

		dst.set_cell(cell + offset, id, atlas, alt)


func compute_chunk_offset(world: Array, cx: int, cy: int) -> Vector2i:
	var ox = 0
	var oy = 0

	# Horizontal offset
	for x in range(cx):
		var c = world[cy][x]
		ox += get_chunk_width(c)

	# Vertical offset
	for y in range(cy):
		var c = world[y][cx]
		oy += get_chunk_height(c)

	return Vector2i(ox, oy)


func get_chunk_width(chunk: Chunk) -> int:
	if chunk.ground:
		return chunk.ground.get_used_rect().size.x
	if chunk.wall:
		return chunk.wall.get_used_rect().size.x
	if chunk.clutter:
		return chunk.clutter.get_used_rect().size.x
	return 0


func get_chunk_height(chunk: Chunk) -> int:
	if chunk.ground:
		return chunk.ground.get_used_rect().size.y
	if chunk.wall:
		return chunk.wall.get_used_rect().size.y
	if chunk.clutter:
		return chunk.clutter.get_used_rect().size.y
	return 0
