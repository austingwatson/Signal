class_name MultiTool
extends Node2D

@export var multi_tool_stats: MultiToolStats
@export var textures: Array[Texture2D] = []
@export var damage: Damage
@export var force_placement := false
var signal_towers: Array[InteractableComponent] = []
var facing_direction := 1
var on_cooldown := false
@onready var sprite := $Sprite2D
@onready var ping_sound := $PingSound
@onready var detection_component := $DetectionComponent
@onready var timer := $Timer
@onready var shoot_sound := $Shoot
@onready var tool_sparks := $ToolSparks

func _ready() -> void:
	var ping_range: CircleShape2D = $PingRange/CollisionShape2D.shape
	ping_range.radius = multi_tool_stats.signal_range
	
	sprite.texture = textures[0]
	
	timer.wait_time = damage.cooldown


func _physics_process(_delta: float) -> void:
	#ping()
	
	look_at(get_global_mouse_position())
	rotation = wrapf(rotation, -PI, PI)
	if force_placement:
		if facing_direction > 0:
			rotation = clamp(rotation, deg_to_rad(-45), deg_to_rad(45))
			sprite.flip_v = false
		elif facing_direction < 0:
			if rotation < 0 and rad_to_deg(rotation) > -135:
				rotation = deg_to_rad(-135)
			elif rotation > 0 and rad_to_deg(rotation) < 115:
				rotation = deg_to_rad(115)
			sprite.flip_v = true
	else:
		if abs(rotation) > PI * 0.5:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
	detection_component.rotation = rotation
	

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
	GlobalSignals.call_ping_changed(distance_factor, angle_factor)
	play_ping_sound(signal_strength)
	if not ping_sound.playing:
		ping_sound.playing = true
	

func stop_ping() -> void:
	GlobalSignals.call_ping_changed(0.0, 0.0)
	ping_sound.playing = false
	

func shoot() -> void:
	if on_cooldown:
		return
	
	## tool_sparks.emitting(true)  Not sure how to make sparks emit on mouse click
	
	var closest = detection_component.get_multi_closest(damage.max_hits)
	for enemy in closest:
		enemy.take_damage(damage.damage)
		var lightning := preload("res://scenes/effect/lightning_effect.tscn").instantiate()
		lightning.set_lightning_points(global_position, enemy.global_position, 3, 6)
		EntityManager.add_entity(lightning)
	
	if closest.size() > 0:
		shoot_sound.play()
		on_cooldown = true
		timer.start()
	

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
		ping_sound.pitch_scale = lerp(multi_tool_stats.slow_ping, multi_tool_stats.fast_ping, signal_strength)
		ping_sound.volume_db = 0.0
	else:
		ping_sound.pitch_scale = 1.0
		ping_sound.volume_db = -80.0


func _on_ping_range_area_entered(area: Area2D) -> void:
	if area is InteractableComponent:
		signal_towers.append(area)


func _on_ping_range_area_exited(area: Area2D) -> void:
	if area is InteractableComponent:
		signal_towers.erase(area)


func _on_timer_timeout() -> void:
	on_cooldown = false
