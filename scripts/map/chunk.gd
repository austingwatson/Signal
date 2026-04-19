class_name Chunk
extends Node2D

@export var exits = {
	"up": false,
	"left": false,
	"down": false,
	"right": false,
}
@export var ground: TileMapLayer = null
@export var wall: TileMapLayer = null
@export var clutter: TileMapLayer = null
@export var spawn: TileMapLayer = null
@export var is_goal_chunk := false
@export_range(0.0, 1.0, 0.01) var spawn_chance := 1.0


func get_chunk_pixel_size() -> Vector2i:
	if ground == null:
		return Vector2i.ZERO
		
	var tile_size = ground.tile_set.tile_size
	var used = ground.get_used_rect()
	
	var pixel_w = used.size.x * tile_size.x
	var pixel_h = used.size.y * tile_size.y
	
	return Vector2i(pixel_w, pixel_h)
