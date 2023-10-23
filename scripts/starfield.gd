class_name Starfield extends Node2D

@onready var starfield_front: GPUParticles2D = $StarfieldFront
@onready var starfield_middle: GPUParticles2D = $StarfieldMiddle
@onready var starfield_back: GPUParticles2D = $StarfieldBack

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func set_starfield() -> void:
	match Global.detail:
		Global.Detail.LOW:
			if starfield_front.visible:
				starfield_front.emitting = false
				starfield_front.visible = false
			if !starfield_middle.visible:
				starfield_middle.emitting = true
				starfield_middle.visible = true
			if starfield_back.visible:
				starfield_back.emitting = false
				starfield_back.visible = false
		Global.Detail.MEDIUM:
			if !starfield_front.visible:
				starfield_front.emitting = true
				starfield_front.visible = true
			if !starfield_middle.visible:
				starfield_middle.emitting = true
				starfield_middle.visible = true
			if starfield_back.visible:
				starfield_back.emitting = false
				starfield_back.visible = false
		Global.Detail.HIGH:
			if !starfield_front.visible:
				starfield_front.emitting = true
				starfield_front.visible = true
			if !starfield_middle.visible:
				starfield_middle.emitting = true
				starfield_middle.visible = true
			if !starfield_back.visible:
				starfield_back.emitting = true
				starfield_back.visible = true
