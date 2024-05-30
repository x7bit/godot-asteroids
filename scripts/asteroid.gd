class_name Asteroid extends RigidBody2D

enum AsteroidSize {SMALL, MEDIUM, LARGE}

signal exploded(pos: Vector2, new_rotation: float, size: Asteroid.AsteroidSize, points: int)

const BASE_SPEED: float = 50.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var cshape: CollisionShape2D = $CollisionShape2D
@onready var indicator: Indicator = $Indicator

@export var size: AsteroidSize = AsteroidSize.LARGE
var center_offset: Vector2 = Vector2.ZERO

var max_speed: float = BASE_SPEED
var speed_multiplier: float = 1.0
var initial_move_angle: float = 0.0
var alfa: float = 1.0
var is_bounced: bool = false

var id: int:
	get:
		return get_instance_id()

var global_center: Vector2:
	get:
		return global_position + center_offset

var move_angle: float:
	get:
		return Util.get_rotation_based_up_vector(linear_velocity)

var radius: float:
	get:
		return cshape.shape.radius

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

var mass_multiplier: float:
	get:
		return pow(2, size) * 2

var indicator_scale: Vector2:
	get:
		match size:
			AsteroidSize.SMALL: return Vector2(0.15, 0.15)
			AsteroidSize.MEDIUM: return Vector2(0.2, 0.2)
			AsteroidSize.LARGE: return Vector2(0.25, 0.25)
			_: return Vector2.ZERO

func _ready() -> void:
	match size:
		AsteroidSize.SMALL:
			mass = 0.1
			max_speed = speed_multiplier * 3.2 * BASE_SPEED
			sprite.texture = preload("res://assets/textures/asteroid_small.png")
			cshape.shape = preload("res://resources/asteroid_cshape_small.tres")
			cshape.position = Vector2(1, -1)
		AsteroidSize.MEDIUM:
			mass = 0.4
			max_speed = speed_multiplier * 2.4 * BASE_SPEED
			sprite.texture = preload("res://assets/textures/asteroid_medium.png")
			cshape.shape = preload("res://resources/asteroid_cshape_medium.tres")
			cshape.position = Vector2.ZERO
		AsteroidSize.LARGE:
			mass = 1.6
			alfa = 0.0
			max_speed = speed_multiplier * 1.7 * BASE_SPEED
			sprite.modulate.a = alfa
			sprite.texture = preload("res://assets/textures/asteroid_large.png")
			cshape.shape = preload("res://resources/asteroid_cshape_large.tres")
			cshape.position = Vector2(0, -4)
	rotation = randf_range(0, 2 * PI)
	center_offset = cshape.position.rotated(rotation)
	indicator.scale = indicator_scale
	indicator.global_rotation = initial_move_angle
	freeze = true

func _integrate_forces(state: PhysicsDirectBodyState2D):
	#MAX SPEED ClAMP
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed
	#OFF SCREEN TRANSITIONS
	var screen_size: Vector2 = get_viewport_rect().size
	var indicator_prev_position: Vector2 = indicator.global_position
	indicator.global_rotation = move_angle
	if (global_position.y + radius) < 0: #UP
		global_position.y = screen_size.y + radius
		indicator.global_position = indicator_prev_position
	elif (global_position.y - radius) > screen_size.y: #DOWN
		global_position.y = -radius
		indicator.global_position = indicator_prev_position
	if (global_position.x + radius) < 0: #LEFT
		global_position.x = screen_size.x + radius
		indicator.global_position = indicator_prev_position
	elif (global_position.x - radius) > screen_size.x: #RIGHT
		global_position.x = -radius
		indicator.global_position = indicator_prev_position

func _process(delta: float) -> void:
	if alfa < 1.0:
		alfa = minf(alfa + 1.5 * delta, 1.0)
		sprite.modulate.a = alfa
	elif freeze:
		freeze = false
		apply_central_impulse(randf_range(max_speed * 0.6, max_speed) * Vector2.UP.rotated(initial_move_angle))

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
	if body is Asteroid:
		if is_bounced:
			is_bounced = false
			SfxController.play_in_unique_player(SfxController.Sfx.BOUNCE)
		else:
			body.is_bounced = true

func init(_pos: Vector2, _move_angle: float, _size: Asteroid.AsteroidSize) -> void:
	global_position = _pos
	size = _size
	initial_move_angle = _move_angle
	speed_multiplier = Global.asteroid_speed_multiplier

func explode(laser: Laser) -> void:
	var new_rotation = Util.get_explosion_rotation(laser, self)
	emit_signal("exploded", global_position, new_rotation, size, points)
	queue_free()
