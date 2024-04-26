extends CanvasLayer

var explosion_particle_material: ParticleProcessMaterial  = preload("res://resources/explosion_particle_material.tres")
var fire1_particle_material: ParticleProcessMaterial  = preload("res://resources/fire1_particle_material.tres")
var fire2_particle_material: ParticleProcessMaterial  = preload("res://resources/fire2_particle_material.tres")
var laser_explosion_particle_material: ParticleProcessMaterial  = preload("res://resources/laser_explosion_particle_material.tres")
var power_up_particle_material: ParticleProcessMaterial  = preload("res://resources/power_up_particle_material.tres")

var blue_orb_sprite:SpriteFrames = preload("res://resources/orb_blue_sprite_frames.tres")
var green_orb_sprite:SpriteFrames = preload("res://resources/orb_green_sprite_frames.tres")
var red_orb_sprite:SpriteFrames = preload("res://resources/orb_red_sprite_frames.tres")

var particles_materials: Array[ParticleProcessMaterial ] = [
	explosion_particle_material,
	fire1_particle_material,
	fire2_particle_material,
	laser_explosion_particle_material,
	power_up_particle_material,
]

var sprites_frames: Array[SpriteFrames] = [
	blue_orb_sprite,
	green_orb_sprite,
	red_orb_sprite,
]

var frames: int = 0
var loaded: bool = false

func _ready():
	for particles_material in particles_materials:
		var gpu_particles = GPUParticles2D.new()
		gpu_particles.process_material = particles_material
		gpu_particles.modulate = Color.TRANSPARENT
		gpu_particles.one_shot = true
		gpu_particles.emitting = true
		add_child(gpu_particles)
	for sprite_frames in sprites_frames:
		var animated_sprite = AnimatedSprite2D.new()
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.modulate = Color.TRANSPARENT
		animated_sprite.play()
		add_child(animated_sprite)

func _process(_delta: float):
	if frames >= 5:
		for child in get_children():
			match child.get_class():
				"GPUParticles2D":
					child.emitting = false
					child.queue_free()
				"AnimatedSprite2D":
					child.stop()
					child.queue_free()
		set_process(false)
		loaded = true
	else:
		frames += 1
