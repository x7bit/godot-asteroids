class_name Player extends CharacterBody2D

signal laser_shoot(laser: Laser)
signal died()

const ROTATION_SPEED := 140.0
const MAX_SPEED := 320.0
const ACCELERATION := 8.0
const DECELERATION := 3.0
const GRAVITY := 1.5
const RATE_OF_LASER := 0.2

const LaserScene: PackedScene = preload("res://scenes/laser.tscn")

@onready var ship_sprite: Sprite2D = $Sprite2D_Ship
@onready var cpoly:CollisionPolygon2D = $CollisionPolygon2D
@onready var muzzles: Array[Node2D] = [$Muzzle1, $Muzzle2]
@onready var thrusts: Array[Sprite2D] = [$Sprite2D_ThrustL, $Sprite2D_ThrustR]
@onready var die_audio: AudioStreamPlayer = $DieAudio
@onready var thrust_audio: AudioStreamPlayer = $ThrustAudio
@onready var die_particles: Array[GPUParticles2D] = [
	$DieParticles/Fire1Particles,
	$DieParticles/Fire2Particles,
	$DieParticles/ExplosionParticles
]

var alive := true
var spawn_pos := Vector2.ZERO
var laser_cooldown := false
var muzzle_idx := 0
var thrust_forward := false
var thrust_alfa := 0.0

func _ready():
	thrust_forward = false
	thrust_alfa = 0.0
	thrusts[0].modulate.a = thrust_alfa
	thrusts[1].modulate.a = thrust_alfa

func _process(delta: float):
	if !alive || !Global.game_started: return
	
	if Input.is_action_just_pressed("move_forward"):
		thrust_forward = true
	if Input.is_action_just_released("move_forward"):
		thrust_forward = false
	if Input.is_action_pressed("shoot") && !laser_cooldown:
		laser_cooldown = true
		shoot()
		await get_tree().create_timer(RATE_OF_LASER).timeout
		laser_cooldown = false
	
	if thrust_forward:
		if !thrust_audio.playing: thrust_audio.play()
		if thrust_alfa < 1.0:
			thrust_alfa = minf(thrust_alfa + (2.14 * delta), 1.0)
			thrusts[0].modulate.a = thrust_alfa
			thrusts[1].modulate.a = thrust_alfa
	else:
		if thrust_audio.playing: thrust_audio.stop()
		if thrust_alfa > 0.0:
			thrust_alfa = maxf(thrust_alfa - (3.57 * delta), 0.0)
			thrusts[0].modulate.a = thrust_alfa
			thrusts[1].modulate.a = thrust_alfa

func _physics_process(delta: float):
	if !alive || !Global.game_started: return
	move(delta)
	move_and_slide()

func move(delta: float):
	if Input.is_action_pressed("move_forward"):
		velocity += Vector2(0, -ACCELERATION).rotated(rotation)
	if Input.is_action_pressed("move_backward"):
		velocity += Vector2(0, DECELERATION).rotated(rotation)
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-ROTATION_SPEED * delta))
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(ROTATION_SPEED * delta))
	
	velocity = velocity.limit_length(MAX_SPEED).move_toward(Vector2.ZERO, GRAVITY)
	
	var screen_size: Vector2 = get_viewport_rect().size
	var player_half_size: Vector2 = Util.get_poly_rect(cpoly.get_polygon(), scale).size / 2
	if (global_position.y + player_half_size.y) < 0:
		global_position.y = screen_size.y + player_half_size.y
	elif (global_position.y - player_half_size.y) > screen_size.y:
		global_position.y = -player_half_size.y
	if (global_position.x + player_half_size.x) < 0:
		global_position.x = screen_size.x + player_half_size.x
	elif (global_position.x - player_half_size.x) > screen_size.x:
		global_position.x = -player_half_size.x

func shoot():
	var muzzle: Node2D = muzzles[muzzle_idx]
	var laser := LaserScene.instantiate()
	laser.global_position = muzzle.global_position
	laser.rotation = rotation
	emit_signal("laser_shoot", laser)
	muzzle_idx = (muzzle_idx + 1) % 2

func die():
	if alive:
		alive = false
		velocity = Vector2.ZERO
		rotation = 0
		die_audio.play()
		if thrust_audio.playing: thrust_audio.stop()
		thrust_forward = false
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

func pre_respawn():
	if !alive:
		ship_sprite.modulate.a = 0.3

func respawn():
	if !alive:
		alive = true
		ship_sprite.modulate.a = 1.0
