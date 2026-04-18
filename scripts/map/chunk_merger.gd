extends Node

func merge_chunks(world: Array, final_ground: TileMapLayer, final_wall: TileMapLayer, final_clutter: TileMapLayer):
	for y in range(world.size()):
		for x in range(world[y].size()):
			var chunk = world[y][x]
			if chunk == null:
				continue

			var offset = compute_chunk_offset(world, x, y)
			merge_layer(chunk.ground, final_ground, offset)
			merge_layer(chunk.wall, final_wall, offset)
			merge_layer(chunk.clutter, final_clutter, offset)


func merge_layer(src: TileMapLayer, dst: TileMapLayer, offset: Vector2i):
	if src == null:
		return

	for cell in src.get_used_cells():
		var id = src.get_cell_source_id(cell)
		var atlas = src.get_cell_atlas_coords(cell)
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
