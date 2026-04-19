class_name FlowField
extends Resource

const INF := 999999.0

var size: Vector2i
var walkable: Array
var cost_field: Array
var flow_field: Array

var ground: TileMapLayer
var wall: TileMapLayer
var clutter: TileMapLayer

var created := false


func setup(ground_layer: TileMapLayer, wall_layer: TileMapLayer, clutter_layer: TileMapLayer) -> void:
	ground = ground_layer
	wall = wall_layer
	clutter = clutter_layer

	size = ground.get_used_rect().size

	# build walkability grid
	walkable = []
	walkable.resize(size.x)

	for x in size.x:
		walkable[x] = []
		walkable[x].resize(size.y)

		for y in size.y:
			var cell := Vector2i(x, y)
			var blocked := false

			if wall.get_cell_source_id(cell) != -1:
				blocked = true
			if clutter.get_cell_source_id(cell) != -1:
				blocked = true

			walkable[x][y] = not blocked


func compute_cost_field(destinations_world: Array[Vector2]) -> void:
	cost_field = []
	cost_field.resize(size.x)

	for x in size.x:
		cost_field[x] = []
		cost_field[x].resize(size.y)
		for y in size.y:
			cost_field[x][y] = INF

	var queue: Array[Vector2i] = []

	# add all destinations
	for world_pos in destinations_world:
		var cell := ground.local_to_map(world_pos)
		if _in_bounds(cell):
			cost_field[cell.x][cell.y] = 0
			queue.append(cell)

	var dirs = [
		Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
		Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)
	]

	while queue.size() > 0:
		var cell = queue.pop_front()
		var cost = cost_field[cell.x][cell.y]

		for dir in dirs:
			var next = cell + dir

			if not _in_bounds(next):
				continue

			# diagonal blocking
			if dir.x != 0 and dir.y != 0:
				var side1 := Vector2i(cell.x + dir.x, cell.y)
				var side2 := Vector2i(cell.x, cell.y + dir.y)

				if not walkable[side1.x][side1.y] or not walkable[side2.x][side2.y]:
					continue

			if not walkable[next.x][next.y]:
				continue

			var move_cost := 1.0
			if dir.x != 0 and dir.y != 0:
				move_cost = 1.4142

			if cost_field[next.x][next.y] > cost + move_cost:
				cost_field[next.x][next.y] = cost + move_cost
				queue.append(next)


func compute_flow_field() -> void:
	flow_field = []
	flow_field.resize(size.x)

	for x in size.x:
		flow_field[x] = []
		flow_field[x].resize(size.y)
		for y in size.y:
			flow_field[x][y] = Vector2.ZERO

	var dirs = [
		Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
		Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)
	]

	for x in size.x:
		for y in size.y:
			if cost_field[x][y] == INF:
				continue

			var cell := Vector2i(x, y)
			var best_cost = cost_field[x][y]
			var best_dir := Vector2.ZERO

			for dir in dirs:
				var next = cell + dir

				if not _in_bounds(next):
					continue

				# diagonal blocking
				if dir.x != 0 and dir.y != 0:
					var side1 := Vector2i(cell.x + dir.x, cell.y)
					var side2 := Vector2i(cell.x, cell.y + dir.y)

					if not walkable[side1.x][side1.y] or not walkable[side2.x][side2.y]:
						continue

				if cost_field[next.x][next.y] < best_cost:
					best_cost = cost_field[next.x][next.y]
					best_dir = Vector2(dir)

			flow_field[x][y] = best_dir.normalized()
			

func smooth_flow_field() -> void:
	var new_field := []
	new_field.resize(size.x)

	for x in size.x:
		new_field[x] = []
		new_field[x].resize(size.y)

		for y in size.y:
			var base = flow_field[x][y]
			if base == Vector2.ZERO:
				new_field[x][y] = Vector2.ZERO
				continue

			var sum = base
			var count := 1

			for ox in range(-1, 2):
				for oy in range(-1, 2):
					if ox == 0 and oy == 0:
						continue

					var nx := x + ox
					var ny := y + oy
					
					if nx < 0 or ny < 0 or nx >= size.x or ny >= size.y:
						continue
					
					var neighbor = flow_field[nx][ny]
					if neighbor != Vector2.ZERO:
						sum += neighbor
						count += 1

			new_field[x][y] = sum.normalized()

	flow_field = new_field



func get_direction(world_pos: Vector2) -> Vector2:
	if not created:
		return Vector2.ZERO
	var cell := ground.local_to_map(world_pos)
	if not _in_bounds(cell):
		return Vector2.ZERO
	return flow_field[cell.x][cell.y]
	

func get_tile_pos(world_position: Vector2) -> Vector2i:
	return ground.local_to_map(world_position)
	

func get_map_pos(tile: Vector2i) -> Vector2:
	return ground.map_to_local(tile)


func _in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y
