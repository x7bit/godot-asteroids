extends CanvasLayer

var explosion_particle_material: Material = preload("res://resources/explosion_particle_material.tres")
var fire1_particle_material: Material = preload("res://resources/fire1_particle_material.tres")
var fire2_particle_material: Material = preload("res://resources/fire2_particle_material.tres")
var laser_explosion_particle_material: Material = preload("res://resources/laser_explosion_particle_material.tres")
var power_up_particle_material: Material = preload("res://resources/power_up_particle_material.tres")

var particles_materials: Array = [
	explosion_particle_material,
	fire1_particle_material,
	fire2_particle_material,
	laser_explosion_particle_material,
	power_up_particle_material,
]

var frames: int = 0
var loaded: bool = false

func _ready():
	for particles_material in particles_materials:
		var particles_instance = GPUParticles2D.new()
		particles_instance.process_material = particles_material
		particles_instance.modulate = Color.TRANSPARENT
		particles_instance.one_shot = true
		particles_instance.emitting = true
		self.add_child(particles_instance)

func _process(_delta: float):
	if frames >= 5:
		set_process(false)
		loaded = true
	else:
		frames += 1
