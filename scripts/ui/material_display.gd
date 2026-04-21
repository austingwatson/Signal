extends Control

@export var player_materials: PlayerMaterials
@onready var metal_label := $VBoxContainer/Metal/Label
@onready var powercell_label := $VBoxContainer/PowerCell/Label


func _process(_delta: float) -> void:
	metal_label.text = str(player_materials.metal)
	powercell_label.text = str(player_materials.power_cell)
