class_name Player extends CharacterBody2D

signal laser_shoot(laser: Laser)
signal poweruped(type: PowerUp.Type)
signal died()

const ROTATION_SPEED: float = 140.0
const MAX_SPEED: float = 320.0
const ACCELERATION: float = 8.0
const DECELERATION: float = 3.0
const GRAVITY: float = 1.5
const RATE_OF_LASER: float = 0.2

const LaserScene: PackedScene = preload("res://scenes/laser.tscn")

@onready var ship_sprite: Sprite2D = $ShipSprite2D
@onready var cpoly:CollisionPolygon2D = $CollisionPolygon2D
@onready var muzzles: Array[Node2D] = [$Muzzle1, $Muzzle2]
@onready var thrusts: Array[Sprite2D] = [$ThrustLSprite2D, $ThrustRSprite2D]
@onready var indicator: Indicator = $Indicator
@onready var die_particles: Array[GPUParticles2D] = [
	$DieParticles/Fire1Particles,
	$DieParticles/Fire2Particles,
	$DieParticles/ExplosionParticles
]

var rotation_speed: float = ROTATION_SPEED
var max_speed: float = MAX_SPEED
var acceleration: float = ACCELERATION
var deceleration: float = DECELERATION
var rate_of_laser: float = RATE_OF_LASER

var alive: bool = true
var spawn_pos: Vector2 = Vector2.ZERO
var laser_input_digital: bool = false
var laser_input_analog: bool = false
var laser_cooldown: bool = false
var muzzle_idx: int = 0
var thrust_forward_digital: bool = false
var thrust_forward_analog: bool = false
var thrust_alfa: float = 0.0

var move_angle: float:
	get:
		return Util.get_rotation_based_up_vector(velocity)

func _ready() -> void:
	thrust_forward_digital = false
	thrust_forward_analog = false
	thrust_alfa = 0.0
	thrusts[0].modulate.a = thrust_alfa
	thrusts[1].modulate.a = thrust_alfa

func _process(delta: float) -> void:
	if !alive || !Global.game_started: return
	#DIGITAL INPUTS
	if Input.is_action_just_pressed("move_forward"):
		thrust_forward_digital = true
	if Input.is_action_just_released("move_forward"):
		thrust_forward_digital = false
	if Input.is_action_just_pressed("shoot"):
		laser_input_digital = true
	if Input.is_action_just_released("shoot"):
		laser_input_digital = false
	#ANALOG INPUTS
	if Global.joypad >= 0:
		thrust_forward_analog = Input.get_joy_axis(Global.joypad, JOY_AXIS_LEFT_Y) < -0.2
		laser_input_analog = Input.get_joy_axis(Global.joypad, JOY_AXIS_TRIGGER_RIGHT) > 0.5
	#THRUSTS FADE IN/OUT
	if thrust_forward_digital || thrust_forward_analog:
		SfxController.play_in_unique_player(SfxController.Sfx.THRUST, get_instance_id())
		if thrust_alfa < 1.0:
			thrust_alfa = minf(thrust_alfa + (2.14 * delta), 1.0)
			thrusts[0].modulate.a = thrust_alfa
			thrusts[1].modulate.a = thrust_alfa
	else:
		SfxController.stop_in_unique_player(SfxController.Sfx.THRUST, get_instance_id())
		if thrust_alfa > 0.0:
			thrust_alfa = maxf(thrust_alfa - (3.57 * delta), 0.0)
			thrusts[0].modulate.a = thrust_alfa
			thrusts[1].modulate.a = thrust_alfa
	#LASER SHOOT
	if (laser_input_digital || laser_input_analog) && !laser_cooldown && !Global.next_round_pause:
		laser_cooldown = true
		shoot()
		await get_tree().create_timer(rate_of_laser).timeout
		laser_cooldown = false

func _physics_process(delta: float) -> void:
	if !alive || !Global.game_started: return
	move(delta)
	move_and_slide()

func move(delta: float) -> void:
	var y_move: bool = false
	var x_move: bool = false
	#DIGITAL INPUTS
	if Input.is_action_pressed("move_forward"):
		velocity += Vector2(0, -acceleration).rotated(rotation)
		y_move = true
	elif Input.is_action_pressed("move_backward"):
		velocity += Vector2(0, deceleration).rotated(rotation)
		y_move = true
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
		x_move = true
	elif Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
		x_move = true
	#ANALOG INPUTS
	if Global.joypad >= 0:
		if !y_move:
			var y_axis = Input.get_joy_axis(Global.joypad, JOY_AXIS_LEFT_Y)
			if y_axis < -0.2 || y_axis > 0.2:
				velocity += Vector2(0, y_axis * acceleration).rotated(rotation)
				y_move = true
		if !x_move:
			var x_axis = Input.get_joy_axis(Global.joypad, JOY_AXIS_LEFT_X)
			if x_axis < -0.2 || x_axis > 0.2:
				rotate(deg_to_rad(x_axis * rotation_speed * delta))
				x_move = true
	#VELOCITY NORMALIZATION
	velocity = velocity.limit_length(max_speed).move_toward(Vector2.ZERO, GRAVITY)
	#OFF SCREEN TRANSITIONS
	var screen_size: Vector2 = get_viewport_rect().size
	var player_half_size: Vector2 = Util.get_poly_rect(cpoly.get_polygon(), scale).size / 2
	var indicator_prev_position: Vector2 = indicator.global_position
	#POSITION
	if (global_position.y + player_half_size.y) < 0: #UP
		global_position.y = screen_size.y + player_half_size.y
		indicator.global_position = indicator_prev_position
	elif (global_position.y - player_half_size.y) > screen_size.y: #DOWN
		global_position.y = -player_half_size.y
		indicator.global_position = indicator_prev_position
	if (global_position.x + player_half_size.x) < 0: #LEFT
		global_position.x = screen_size.x + player_half_size.x
		indicator.global_position = indicator_prev_position
	elif (global_position.x - player_half_size.x) > screen_size.x: #RIGHT
		global_position.x = -player_half_size.x
		indicator.global_position = indicator_prev_position

func shoot() -> void:
	var muzzle: Node2D = muzzles[muzzle_idx]
	var laser := LaserScene.instantiate()
	laser.global_position = muzzle.global_position
	laser.rotation = rotation
	emit_signal("laser_shoot", laser)
	muzzle_idx = (muzzle_idx + 1) % 2

func die() -> void:
	if alive:
		alive = false
		velocity = Vector2.ZERO
		rotation = 0
		SfxController.stop_in_unique_player(SfxController.Sfx.THRUST, get_instance_id())
		thrust_forward_digital = false
		thrust_forward_analog = false
		thrust_alfa = 0.0
		thrusts[0].modulate.a = thrust_alfa
		thrusts[1].modulate.a = thrust_alfa
		ship_sprite.modulate.a = 0.0
		var die_pos := Vector2(global_position)
		global_position = spawn_pos
		for i in 3:
			die_particles[i].global_position = die_pos
			die_particles[i].emitting = true
		emit_signal("died")

func powerup(type: PowerUp.Type) -> void:
	match type:
		PowerUp.Type.LASER:
			rate_of_laser *= 0.85
		PowerUp.Type.TURN:
			rotation_speed *= 1.15
		PowerUp.Type.SPEED:
			max_speed *= 1.15
			acceleration *= 1.15
			deceleration *= 1.15
	emit_signal("poweruped", type)

func pre_respawn() -> void:
	if !alive:
		ship_sprite.modulate.a = 0.4

func respawn() -> void:
	if !alive:
		alive = true
		ship_sprite.modulate.a = 1.0

func new_game() -> void:
	alive = true
	ship_sprite.modulate.a = 1.0
	rotation_speed = ROTATION_SPEED
	max_speed = MAX_SPEED
	acceleration = ACCELERATION
	deceleration = DECELERATION
	rate_of_laser = RATE_OF_LASER
