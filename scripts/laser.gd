class_name Laser extends Area2D

const SPEED := 700.0
const RANGE := 600.0

@onready var laser_sprite: Sprite2D = $Sprite2D
@onready var laser_cshape: CollisionShape2D = $CollisionShape2D
@onready var laser_explosion: GPUParticles2D = $LaserExplosionParticles

var exploded := false
var distance := 0.0

func _ready():
	exploded = false

func _process(delta: float):
	if exploded: return
	var frame_distance := SPEED * delta
	global_position += Vector2.UP.rotated(rotation) * frame_distance
	distance += frame_distance
	if distance > RANGE:
		queue_free()
	else:
		var screen_size: Vector2 = get_viewport_rect().size
		var laser_half_size: Vector2 = laser_cshape.shape.get_rect().size / 2
		if (global_position.y + laser_half_size.y) < 0: #UP
			global_position.y = screen_size.y + laser_half_size.y
		elif (global_position.y - laser_half_size.y) > screen_size.y: #DOWN
			global_position.y = -laser_half_size.y
		if (global_position.x + laser_half_size.x) < 0: #LEFT
			global_position.x = screen_size.x + laser_half_size.x
		elif (global_position.x - laser_half_size.x) > screen_size.x: #RIGHT
			global_position.x = -laser_half_size.x

func explode_and_free(explosion_scale: float):
	exploded = true
	laser_sprite.visible = false
	laser_explosion.lifetime *= explosion_scale
	laser_explosion.emitting = true
	await get_tree().create_timer(laser_explosion.lifetime + 0.1).timeout
	queue_free()
