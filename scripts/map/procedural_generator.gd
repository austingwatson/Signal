extends Node

const CHUNK_FOLDER := "res://scenes/map/chunk/"
const OPPOSITE := {
	"up": "down",
	"down": "up",
	"left": "right",
	"right": "left"
}
var chunk_library: Array[PackedScene] = []

# ---------------------------------------------------------
# PUBLIC: Build a fully connected world with goals
# ---------------------------------------------------------
func build_world(chunk_library: Array[PackedScene], chunk_w: int, chunk_h: int, goal_count: int) -> Array:
	self.chunk_library = chunk_library
	
	var world := generate_base_world(chunk_w, chunk_h)
	ensure_world_connectivity(world)
	place_goals(world, goal_count)

	return world


# ---------------------------------------------------------
# BASE WORLD GENERATION
# ---------------------------------------------------------
func generate_base_world(chunk_w: int, chunk_h: int) -> Array:
	var world := []
	for y in range(chunk_h):
		world.append([])
		for x in range(chunk_w):
			world[y].append(null)

	# Starting chunk must be valid for (0,0)
	world[0][0] = get_valid_starting_chunk()

	for y in range(chunk_h):
		for x in range(chunk_w):
			if world[y][x] == null:
				var required = required_connection(world, x, y)
				world[y][x] = find_matching_chunk(world, x, y, required)

	return world


# ---------------------------------------------------------
# STARTING CHUNK MUST NOT HAVE UP/LEFT EXITS
# ---------------------------------------------------------
func get_valid_starting_chunk():
	var valid := []
	for scene in chunk_library:
		var inst: Chunk = scene.instantiate()
		if inst.exits["up"] or inst.exits["left"]:
			inst.free()
			continue
		inst.free()
		valid.append(scene)

	if valid.is_empty():
		return chunk_library.pick_random().instantiate()

	return valid.pick_random().instantiate()


# ---------------------------------------------------------
# DETERMINE REQUIRED EXIT BASED ON NEIGHBORS
# ---------------------------------------------------------
func required_connection(world, x, y) -> String:
	var checks = [
		{"dir": "left",  "cond": x > 0 and world[y][x - 1] and world[y][x - 1].exits["right"]},
		{"dir": "right", "cond": x < world[y].size() - 1 and world[y][x + 1] and world[y][x + 1].exits["left"]},
		{"dir": "up",    "cond": y > 0 and world[y - 1][x] and world[y - 1][x].exits["down"]},
		{"dir": "down",  "cond": y < world.size() - 1 and world[y + 1][x] and world[y + 1][x].exits["up"]}
	]
	checks.shuffle()

	for c in checks:
		if c["cond"]:
			return c["dir"]
	return ""


# ---------------------------------------------------------
# FIND A LOCALLY VALID CHUNK
# ---------------------------------------------------------
func find_matching_chunk(world, x, y, required_dir: String):
	var needed = null
	if required_dir != "":
		needed = OPPOSITE[required_dir]

	var matches := []

	for scene in chunk_library:
		var inst: Chunk = scene.instantiate()

		if needed != null and not inst.exits[needed]:
			inst.free()
			continue

		if not chunk_fits_neighbors(inst, world, x, y):
			inst.free()
			continue

		inst.free()
		matches.append(scene)

	if matches.is_empty():
		return chunk_library.pick_random().instantiate()

	return matches.pick_random().instantiate()


# ---------------------------------------------------------
# LOCAL VALIDATION: Does this chunk fit its neighbors?
# ---------------------------------------------------------
func chunk_fits_neighbors(chunk: Chunk, world, x: int, y: int) -> bool:
	if chunk.exits["up"]:
		if y == 0:
			return false
		var above = world[y - 1][x]
		if above != null and not above.exits["down"]:
			return false

	if chunk.exits["down"]:
		if y == world.size() - 1:
			return false
		var below = world[y + 1][x]
		if below != null and not below.exits["up"]:
			return false

	if chunk.exits["left"]:
		if x == 0:
			return false
		var left = world[y][x - 1]
		if left != null and not left.exits["right"]:
			return false

	if chunk.exits["right"]:
		if x == world[y].size() - 1:
			return false
		var right = world[y][x + 1]
		if right != null and not right.exits["left"]:
			return false

	return true


# ---------------------------------------------------------
# GLOBAL CONNECTIVITY: Ensure no isolated chunks
# ---------------------------------------------------------
func ensure_world_connectivity(world: Array) -> void:
	var reachable = flood_fill_reachable(world)

	for y in range(world.size()):
		for x in range(world[y].size()):
			var pos = Vector2i(x, y)
			if not reachable.has(pos):
				world[y][x] = find_connecting_replacement(world, x, y)


# ---------------------------------------------------------
# FLOOD FILL FROM STARTING CHUNK
# ---------------------------------------------------------
func flood_fill_reachable(world: Array) -> Dictionary:
	var visited := {}
	var queue := [Vector2i(0, 0)]
	visited[Vector2i(0, 0)] = true

	var dirs = {
		"up": Vector2i(0, -1),
		"down": Vector2i(0, 1),
		"left": Vector2i(-1, 0),
		"right": Vector2i(1, 0)
	}

	while queue.size() > 0:
		var pos = queue.pop_front()
		var chunk: Chunk = world[pos.y][pos.x]

		for dir in dirs.keys():
			if chunk.exits[dir]:
				var np = pos + dirs[dir]

				if np.x < 0 or np.y < 0 or np.y >= world.size() or np.x >= world[0].size():
					continue

				var neighbor: Chunk = world[np.y][np.x]
				if neighbor == null:
					continue

				if not neighbor.exits[OPPOSITE[dir]]:
					continue

				if not visited.has(np):
					visited[np] = true
					queue.append(np)

	return visited


# ---------------------------------------------------------
# FIX ISOLATED CHUNKS BY REPLACING THEM
# ---------------------------------------------------------
func find_connecting_replacement(world, x, y):
	var neighbors := {
		"up": null,
		"down": null,
		"left": null,
		"right": null
	}

	if y > 0:
		neighbors["up"] = world[y - 1][x]
	if y < world.size() - 1:
		neighbors["down"] = world[y + 1][x]
	if x > 0:
		neighbors["left"] = world[y][x - 1]
	if x < world[y].size() - 1:
		neighbors["right"] = world[y][x + 1]

	var valid := []

	for scene in chunk_library:
		var inst: Chunk = scene.instantiate()
		var ok = true

		for dir in neighbors.keys():
			var n = neighbors[dir]
			if n == null:
				continue

			if n.exits[OPPOSITE[dir]] and not inst.exits[dir]:
				ok = false
				break

		if ok:
			valid.append(scene)
		inst.free()

	var old_chunk = world[y][x]
	if old_chunk:
		old_chunk.free()

	if valid.is_empty():
		return chunk_library.pick_random().instantiate()

	return valid.pick_random().instantiate()


# ---------------------------------------------------------
# GOAL / TOWER PLACEMENT
# ---------------------------------------------------------
func place_goals(world: Array, goal_count: int):
	var candidates := []

	# Collect all chunks that CAN be goals (marked in editor)
	for y in range(world.size()):
		for x in range(world[y].size()):
			var chunk: Chunk = world[y][x]
			if chunk.is_goal_chunk:
				candidates.append(Vector2i(x, y))

	if candidates.is_empty():
		push_warning("No goal-capable chunks exist!")
		return

	# Reset ALL chunks to non-goal before selecting actual goals
	for y in range(world.size()):
		for x in range(world[y].size()):
			world[y][x].is_goal_chunk = false

	# Choose first goal randomly
	var chosen := []
	chosen.append(candidates.pick_random())

	# Spread out remaining goals
	while chosen.size() < goal_count and candidates.size() > 0:
		var best_pos = null
		var best_dist = -1

		for pos in candidates:
			var min_dist = INF
			for c in chosen:
				var d = pos.distance_to(c)
				if d < min_dist:
					min_dist = d

			if min_dist > best_dist:
				best_dist = min_dist
				best_pos = pos

		chosen.append(best_pos)
		candidates.erase(best_pos)

	# Mark chosen chunks as actual goals
	for pos in chosen:
		world[pos.y][pos.x].is_goal_chunk = true
