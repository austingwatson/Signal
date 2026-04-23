class_name Wave
extends Resource

@export var swarm_bots := 0
@export var swarm_bot_clump := 0
@export var heavy_bots := 0
@export var heavy_bot_clump := 0
@export_range(0.5, 10.0, 0.1) var spawn_rate := 0.0
@export var next_wave_timer := 0.0
