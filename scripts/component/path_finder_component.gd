class_name PathFinderComponent
extends Node2D

@export var character_movement_component: CharacterMovementComponent

var flow_field: FlowField = preload("res://scripts/map/flow_field.tres")
var use_flowfield := true

var current_tile := Vector2i.ZERO
var final_tile := Vector2i.ZERO


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
