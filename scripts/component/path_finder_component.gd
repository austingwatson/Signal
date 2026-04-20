class_name PathFinderComponent
extends Node2D

@export var separation_radius := 20.0
@export var avoidance_radius := 32.0
@export var flow_dir_weight := 1.0
@export var separation_weight := 1.4
@export var avoidance_weight := 0.8
@export var character_movement_component: CharacterMovementComponent

var flow_field: FlowField = preload("res://scripts/map/flow_field.tres")
var use_flowfield := false

var current_tile := Vector2i.ZERO
var final_tile := Vector2i.ZERO


func path_find() -> void:
	if use_flowfield:
		_flow_field()
	

func _flow_field() -> void:
	var flow := flow_field.get_direction(global_position)
	character_movement_component.set_direction(flow)
	return
	var flow_dir := flow_field.get_direction(global_position)
	var separation_dir := _get_seperation_dir()
	var avoidance_dir := _get_avoidance_dir()
	
	var dir := flow_dir * flow_dir_weight + separation_dir * separation_weight + avoidance_dir * avoidance_weight
	
	character_movement_component.set_direction(dir)
	

func _get_seperation_dir() -> Vector2:
	var push := Vector2.ZERO
	var count := 0
	
	for other in get_tree().get_nodes_in_group("enemy"):
		var offset = global_position - other.global_position
		var dist = offset.length()

		if dist < separation_radius:
			push += offset.normalized() * (1.0 - dist / separation_radius)
			count += 1
		
	if count > 0:
		push /= count
	
	return push


func _get_avoidance_dir() -> Vector2:
	var avoid := Vector2.ZERO
	
	for other in get_tree().get_nodes_in_group("enemy"):
		var offset: Vector2 = other.global_position - global_position
		var dist := offset.length()
		
		if dist < avoidance_radius:
			if character_movement_component.velocity.dot(offset) > 0:
				avoid -= offset.normalized() * (1.0 - dist / avoidance_radius)
	
	return avoid


func request_next_tile() -> Vector2i:
	current_tile = flow_field.get_tile_pos(global_position)
	var dir := flow_field.get_direction(global_position)
	
	if dir == Vector2.ZERO:
		return current_tile
	
	return current_tile + Vector2i(round(dir.x), round(dir.y))
	

func find_fallback_tile(reservations: Dictionary) -> Vector2i:
	var neighbors = [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1)
	]
	
	for n in neighbors:
		var t = current_tile + n
		if flow_field._in_bounds(t) and not reservations.has(t):
			return t
	
	final_tile = current_tile
	return current_tile
	

func apply_reserved_tile() -> void:
	if final_tile == current_tile:
		return
		
	var world_target := flow_field.get_map_pos(final_tile)
	var dir := (world_target - global_position).normalized()
	character_movement_component.set_direction(dir)
	
	current_tile = final_tile
