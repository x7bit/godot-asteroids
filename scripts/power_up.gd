class_name PowerUp extends Area2D

enum Type { LASER, TURN, SPEED }

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D

var type: Type = Type.LASER
var laser_hits: int = 0
var to_free: bool = false
var alfa: float = 1.0

func _ready() -> void:
	change_type()
	animated_sprite.play()

func _process(delta: float) -> void:
	if to_free:
		alfa -= delta * 4.0
		if alfa > 0.0:
			animated_sprite.modulate.a = alfa
		else:
			queue_free()

func init(_pos: Vector2) -> void:
	global_position = _pos
	type = randi_range(0, 2) as Type
	if type == Global.last_powerup:
		type = randi_range(0, 2) as Type
	Global.last_powerup = type

func _on_area_entered(area: Area2D):
	if  !to_free && area is Laser:
		area.explode_and_free(0.5)
		laser_hits += 1
		if laser_hits > 0 && (laser_hits % 5) == 0:
			type = ((type + 1) % 3) as Type
			change_type()
			animated_sprite.play()

func _on_body_entered(body: Node2D) -> void:
	if !to_free && body is Player:
		body.powerup(type)
		to_free = true
		particles.emitting = false
		SfxController.play(SfxController.Sfx.POWERUP)

func change_type() -> void:
	match type:
		Type.LASER:
			animated_sprite.sprite_frames = preload("res://resources/orb_green_sprite_frames.tres")
			particles.modulate = Color(0.6, 1.0, 0.6)
		Type.TURN:
			animated_sprite.sprite_frames = preload("res://resources/orb_red_sprite_frames.tres")
			particles.modulate = Color(1.0, 0.6, 0.6)
		Type.SPEED:
			animated_sprite.sprite_frames = preload("res://resources/orb_blue_sprite_frames.tres")
			particles.modulate = Color(0.3, 0.7, 1.0)
