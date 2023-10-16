class_name Starfield extends Node2D

const StarfieldBackScene: PackedScene = preload("res://scenes/starfield_back.tscn")
const StarfieldMiddleScene: PackedScene = preload("res://scenes/starfield_middle.tscn")
const StarfieldFrontScene: PackedScene = preload("res://scenes/starfield_front.tscn")

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func set_starfield() -> void:
	match Global.detail:
		Global.Detail.LOW:
			match get_children().size():
				0:
					call_deferred("add_child", StarfieldBackScene.instantiate())
				1:
					pass
				_:
					for i in get_children().size() - 1:
						get_children()[-i-1].queue_free()
		Global.Detail.MEDIUM:
			match get_children().size():
				0:
					call_deferred("add_child", StarfieldBackScene.instantiate())
					call_deferred("add_child", StarfieldMiddleScene.instantiate())
				1:
					call_deferred("add_child", StarfieldMiddleScene.instantiate())
				2:
					pass
				_:
					for i in get_children().size() - 2:
						get_children()[-i-1].queue_free()
		Global.Detail.HIGH:
			match get_children().size():
				0:
					call_deferred("add_child", StarfieldBackScene.instantiate())
					call_deferred("add_child", StarfieldMiddleScene.instantiate())
					call_deferred("add_child", StarfieldFrontScene.instantiate())
				1:
					call_deferred("add_child", StarfieldMiddleScene.instantiate())
					call_deferred("add_child", StarfieldFrontScene.instantiate())
				2:
					call_deferred("add_child", StarfieldFrontScene.instantiate())
				3:
					pass
				_:
					for i in get_children().size() - 3:
						get_children()[-i-1].queue_free()
