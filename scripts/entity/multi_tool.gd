class_name MultiTool
extends Node2D

@export var multi_tool_stats: MultiToolStats
@export var textures: Array[Texture2D] = []
var signal_towers: Array[InteractableComponent] = []
var facing_direction := 1
@onready var sprite := $Sprite2D


func _ready() -> void:
	var ping_range: CircleShape2D = $PingRange/CollisionShape2D.shape
	ping_range.radius = multi_tool_stats.signal_range
	
	sprite.texture = textures[0]


func _physics_process(_delta: float) -> void:
	ping()
	
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
	var mouse_dir := (get_global_mouse_position() - global_position).normalized()
	
	var distance := to_tower.length()
	var distance_factor: float = clamp(1.0 - (distance / multi_tool_stats.signal_range), 0.0, 1.0)
	
	var tower_dir := to_tower.normalized()
	var angle_factor: float = clamp(mouse_dir.dot(tower_dir), 0.0, 1.0)
	
	var signal_strength := distance_factor * angle_factor
	

func find_closest_signal_tower() -> InteractableComponent:
	var closest_tower: InteractableComponent = null
	var closest_distance := 100000.0
	for signal_tower in signal_towers:
		var distance := global_position.distance_to(signal_tower.global_position)
		if distance < closest_distance:
			closest_tower = signal_tower
			closest_distance = distance
	return closest_tower


func _on_ping_range_area_entered(area: Area2D) -> void:
	if area is InteractableComponent:
		signal_towers.append(area)


func _on_ping_range_area_exited(area: Area2D) -> void:
	if area is InteractableComponent:
		signal_towers.erase(area)
