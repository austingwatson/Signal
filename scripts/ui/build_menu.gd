class_name BuildMenu
extends Node2D

@export var player: Node2D
@export var player_materials: PlayerMaterials
@export var radius := 150.0
@export var build_costs: Array[BuildCost] = []   # one icon per slice
@export var line_color := Color.WHITE
@export var line_width := 3.0

var hovered_slice := -1


func _ready():
	close()
	queue_redraw()
	
	GlobalSignals.added_metal.connect(_on_added_metal)
	GlobalSignals.added_power_cell.connect(_on_added_power_cell)
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		hovered_slice = get_slice_from_pos(to_local(get_global_mouse_position()))
		queue_redraw()

	if event is InputEventMouseButton and event.pressed:
		var i = get_slice_from_pos(to_local(get_global_mouse_position()))
		if i != -1:
			try_to_buy(build_costs[i])
			

func _draw():
	var angle_step = TAU / build_costs.size()

	# Draw slices + icons
	for i in range(build_costs.size()):
		var start_angle = i * angle_step

		# Separator line
		var line_end = Vector2(cos(start_angle), sin(start_angle)) * radius
		draw_line(Vector2.ZERO, line_end, line_color, line_width)

		# Icon
		var mid_angle = start_angle + angle_step * 0.5
		var pos = Vector2(cos(mid_angle), sin(mid_angle)) * (radius * 0.55)
		var tex = build_costs[i].icon
		var tex_size = tex.get_size() * 0.5
		draw_texture(tex, pos - tex_size)
		
		# highlight selected icon

	# Final closing line
	var final_line_end = Vector2(cos(0), sin(0)) * radius
	draw_line(Vector2.ZERO, final_line_end, line_color, line_width)
	
	
func open() -> void:
	visible = true
	set_process_unhandled_input(true)
	

func close() -> void:
	visible = false
	set_process_unhandled_input(false)
	

# TODO Need to make it to where the turret you buy follows until you press interact to place it
func try_to_buy(build_cost: BuildCost) -> void:
	if player_materials.can_afford(build_cost):
		player_materials.buy(build_cost)
		var spawn := build_cost.spawn_scene.instantiate()
		spawn.global_position = global_position
		if spawn.has_node("FollowComponent"):
			spawn.get_node("FollowComponent").follow(player.get_node("MultiTool"))
		EntityManager.add_entity(spawn)
		close()
	

func get_slice_from_pos(pos: Vector2) -> int:
	var angle = atan2(pos.y, pos.x)
	if angle < 0:
		angle += TAU
	return int(angle / (TAU / build_costs.size()))
	

func _on_added_metal(amount: int) -> void:
	player_materials.add_metal(amount)
	

func _on_added_power_cell(amount: int) -> void:
	player_materials.add_power_cell(amount)
