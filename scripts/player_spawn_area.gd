class_name PlayerSpawnArea extends Area2D

var is_empty: bool:
	get:
		return !has_overlapping_areas() && !has_overlapping_bodies()

func _ready():
	pass

func _process(_delta: float):
	pass
