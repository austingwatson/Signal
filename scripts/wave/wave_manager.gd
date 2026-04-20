class_name WaveManager
extends Node2D

@export var flow_field: FlowField
@export var waves: Array[Wave] = []
@export var swarm_bot_scene: PackedScene
@export var min_dist := 200.0
@export var max_dist := 400.0
@export var steps := 32

var towers := []
var current_wave := 0
var spawning := false


func _ready() -> void:
	GlobalSignals.activate_tower.connect(_on_activate_tower)
	GlobalSignals.deactivate_tower.connect(_on_deactivate_tower)
	
	spawn_next_wave()
	

func change_towers(amount: int) -> void:
	current_wave += amount
	current_wave = clampi(current_wave, 0, waves.size() - 1)


func spawn_next_wave() -> void:
	while true:
		var wave := waves[current_wave]
		await spawn_wave(wave)
		await get_tree().create_timer(wave.next_wave_timer).timeout
		

func spawn_wave(wave: Wave) -> void:
	for i in range(wave.swarm_bots):
		spawn()
		await get_tree().create_timer(wave.spawn_rate).timeout

func spawn():
	if towers.size() == 0:
		return
	
	var pos := get_position_near_tower(towers.pick_random())
	var swarm_bot := swarm_bot_scene.instantiate()
	swarm_bot.global_position = pos
	swarm_bot.add_to_group("horde")
	EntityManager.add_enemy(swarm_bot)
	

func get_position_near_tower(tower: Node2D) -> Vector2:
	for i in range(steps):
		var angle = randf() * TAU
		var dist = randf_range(min_dist, max_dist)
		var pos = tower.global_position + Vector2(cos(angle), sin(angle)) * dist
		
		if is_visible_to_camera(pos):
			continue
		if not is_valid_flowfield_position(pos):
			continue
		
		return pos
	
	return find_nearest_valid_pos(tower.global_position, max_dist)
	

func find_nearest_valid_pos(origin: Vector2, radius: float) -> Vector2:
	for i in range(steps):
		var angle = TAU * float(i) / steps
		var pos = origin + Vector2(cos(angle), sin(angle)) * radius
		
		if is_valid_flowfield_position(pos) and not is_visible_to_camera(pos):
			return pos
	return origin
	

func is_valid_flowfield_position(pos: Vector2) -> bool:
	var dir := flow_field.get_direction(pos)
	return dir != Vector2.ZERO
	

func is_visible_to_camera(pos: Vector2) -> bool:
	var screen_pos := world_to_screen(pos)
	var rect = get_viewport_rect()
	return rect.has_point(screen_pos)


func world_to_screen(world_pos: Vector2) -> Vector2:
	var vp := get_viewport()
	return vp.get_screen_transform() * world_pos
	

func screen_to_world(screen_pos: Vector2) -> Vector2:
	var vp := get_viewport()
	return vp.get_screen_transform().affine_inverse() * screen_pos

	

func _on_activate_tower(tower) -> void:
	towers.append(tower)
	change_towers(1)
	

func _on_deactivate_tower(tower) -> void:
	towers.erase(tower)
	change_towers(-1)
