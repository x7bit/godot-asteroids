class_name PlayerSpawnArea extends Area2D

var is_empty: bool:
	get:
		return !has_overlapping_areas()

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
