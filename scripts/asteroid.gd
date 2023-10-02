class_name Asteroid extends Area2D

enum AsteroidSize{SMALL, MEDIUM, LARGE}

signal exploded(pos: Vector2, laser_rotation: float, size: Asteroid.AsteroidSize, points: int)

const BASE_SPEED := 50.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var cshape: CollisionShape2D = $CollisionShape2D

@export var size := AsteroidSize.LARGE
var speed := BASE_SPEED
var speed_multiplier := 1.0
var alfa := 1.0

var points: int:
	get:
		match size:
			AsteroidSize.SMALL: return 100
			AsteroidSize.MEDIUM: return 50
			AsteroidSize.LARGE: return 25
			_: return 0

var explosion_scale: float:
	get:
		match size:
			AsteroidSize.SMALL: return 0.4
			AsteroidSize.MEDIUM: return 0.5
			AsteroidSize.LARGE: return 0.8
			_: return 0.0

func _ready():
	match size:
		AsteroidSize.SMALL:
			speed = randf_range(speed_multiplier * 2.5 * BASE_SPEED, speed_multiplier * 3.5 * BASE_SPEED)
			sprite.texture = preload("res://assets/textures/asteroid_small.png")
			cshape.shape = preload("res://resources/asteroid_cshape_small.tres")
		AsteroidSize.MEDIUM:
			speed = randf_range(speed_multiplier * 1.5 * BASE_SPEED, speed_multiplier * 2.5 * BASE_SPEED)
			sprite.texture = preload("res://assets/textures/asteroid_medium.png")
			cshape.shape = preload("res://resources/asteroid_cshape_medium.tres")
		AsteroidSize.LARGE:
			alfa = 0.0
			speed = randf_range(speed_multiplier * BASE_SPEED, speed_multiplier * 1.5 * BASE_SPEED)
			sprite.modulate.a = alfa
			sprite.texture = preload("res://assets/textures/asteroid_large.png")
			cshape.shape = preload("res://resources/asteroid_cshape_large.tres")


func _process(delta: float):
	if alfa < 1.0:
		alfa = minf(alfa + 1.5 * delta, 1.0)
		sprite.modulate.a = alfa
	else:
		global_position += Vector2.UP.rotated(rotation) * speed * delta
		var screen_size: Vector2 = get_viewport_rect().size
		var asteroid_half_size: Vector2 = cshape.shape.get_rect().size / 2
		if (global_position.y + asteroid_half_size.y) < 0:
			global_position.y = screen_size.y + asteroid_half_size.y
		elif (global_position.y - asteroid_half_size.y) > screen_size.y:
			global_position.y = -asteroid_half_size.y
		if (global_position.x + asteroid_half_size.x) < 0:
			global_position.x = screen_size.x + asteroid_half_size.x
		elif (global_position.x - asteroid_half_size.x) > screen_size.x:
			global_position.x = -asteroid_half_size.x

func _on_area_entered(area: Area2D):
	if area is Laser:
		if !area.exploded:
			explode(area)
			area.explode_and_free(explosion_scale)

func _on_body_entered(body: CharacterBody2D):
	if body is Player:
		body.die()

func explode(laser: Laser):
	var new_rotation = Util.get_explosion_rotation(laser, self)
	emit_signal("exploded", global_position, new_rotation, size, points)
	queue_free()
