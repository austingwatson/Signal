class_name MultiTool
extends Node2D

@export var multi_tool_stats: MultiToolStats
@export var textures: Array[Texture2D] = []
var signal_towers: Array[InteractableComponent] = []
var facing_direction := 1
@onready var sprite := $Sprite2D
@onready var ping_sound := $PingSound


func _ready() -> void:
	var ping_range: CircleShape2D = $PingRange/CollisionShape2D.shape
	ping_range.radius = multi_tool_stats.signal_range
	
	sprite.texture = textures[0]


func _physics_process(_delta: float) -> void:
	#ping()
	
	look_at(get_global_mouse_position())
	rotation = wrapf(rotation, -PI, PI)
	if facing_direction > 0:
		rotation = clamp(rotation, deg_to_rad(-45), deg_to_rad(45))
		sprite.flip_v = false
	elif facing_direction < 0:
		if rotation < 0 and rad_to_deg(rotation) > -135:
			rotation = deg_to_rad(-135)
		elif rotation > 0 and rad_to_deg(rotation) < 115:
			rotation = deg_to_rad(115)
		sprite.flip_v = true
	

func ping() -> void:
	var signal_tower := find_closest_signal_tower()
	if signal_tower == null:
		return
	
	var to_tower := signal_tower.global_position - global_position
	
	var distance := to_tower.length()
	var distance_factor: float = clamp(1.0 - (distance / multi_tool_stats.signal_range), 0.0, 1.0)
	#distance_factor = pow(distance_factor, 2.0)
	
	var tool_dir := Vector2.RIGHT.rotated(rotation)
	var tower_dir := to_tower.normalized()
	var angle_factor: float = clamp(tool_dir.dot(tower_dir), 0.0, 1.0)
	
	var signal_strength = (distance_factor * multi_tool_stats.distance_worth) * (angle_factor * multi_tool_stats.angle_worth)
	play_ping_sound(signal_strength)
	

func find_closest_signal_tower() -> InteractableComponent:
	var closest_tower: InteractableComponent = null
	var closest_distance := 100000.0
	for signal_tower in signal_towers:
		var distance := global_position.distance_to(signal_tower.global_position)
		if distance < closest_distance:
			closest_tower = signal_tower
			closest_distance = distance
	return closest_tower
	

func play_ping_sound(signal_strength) -> void:
	if signal_strength > 0.0:
		ping_sound.volume_db = 0
		ping_sound.pitch_scale = lerp(multi_tool_stats.slow_ping, multi_tool_stats.fast_ping, signal_strength)
		ping_sound.play()
	else:
		ping_sound.volume_db = -80
		ping_sound.play()


func _on_ping_range_area_entered(area: Area2D) -> void:
	if area is InteractableComponent:
		signal_towers.append(area)


func _on_ping_range_area_exited(area: Area2D) -> void:
	if area is InteractableComponent:
		signal_towers.erase(area)
