extends Node2D

const AsteroidScene: PackedScene = preload("res://scenes/asteroid.tscn")

@onready var ui_hud: Control = $UI/HUD
@onready var ui_menu: Control = $UI/Menu
@onready var player: CharacterBody2D = $Player
@onready var lasers: Node2D = $Lasers
@onready var asteroids: Node2D = $Asteroids
@onready var starfield: Node2D = $Starfield
@onready var player_spawn_pos: Node2D = $PlayerSpawnPos
@onready var player_spawn_area: Area2D = $PlayerSpawnPos/PlayerSpawnArea
@onready var laser_audio: AudioStreamPlayer = $Audio/LaserAudio
@onready var hit_audio: AudioStreamPlayer = $Audio/HitAudio

func _ready():
	Global.init()
	starfield.load_starfield()
	ui_menu.update()
	ui_menu.connect("change_options", _on_change_options)
	_on_change_options()
	if Global.game_started:
		ui_hud.update()
		ui_hud.visible = true
		ui_menu.visible = false
		player.spawn_pos = player_spawn_pos.global_position
		player.connect("laser_shoot", _on_player_laser_shoot)
		player.connect("died", _on_player_died)
		next_round(true)
	else:
		ui_hud.visible = false
		player.visible = false
		ui_menu.show_menu(ui_menu.MenuFace.MAIN)

func _process(_delta: float):
	if Input.is_action_pressed("pause") && Global.lives > 0:
		get_tree().paused = true
		ui_menu.show_menu(ui_menu.MenuFace.PAUSE)
	
	if Global.game_started && asteroids.get_children().size() == 0:
		next_round(false)

func _on_change_options():
	match Global.window_mode:
		Global.WindowMode.WINDOW:
			if get_tree().get_root().mode != Window.MODE_WINDOWED:
				get_tree().get_root().mode = Window.MODE_WINDOWED
		Global.WindowMode.FULLSCREEN:
			if get_tree().get_root().mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
				get_tree().get_root().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	
	match Global.detail:
		Global.Detail.LOW:
			if texture_filter != TEXTURE_FILTER_NEAREST:
				texture_filter = TEXTURE_FILTER_NEAREST
		Global.Detail.MEDIUM:
			if texture_filter != TEXTURE_FILTER_PARENT_NODE:
				texture_filter = TEXTURE_FILTER_PARENT_NODE
		Global.Detail.HIGH:
			if texture_filter != TEXTURE_FILTER_PARENT_NODE:
				texture_filter = TEXTURE_FILTER_PARENT_NODE
	
	starfield.load_starfield()

func _on_player_laser_shoot(laser: Laser):
	laser_audio.play()
	lasers.add_child(laser)

func _on_player_died():
	Global.lives -= 1
	ui_hud.update()
	if Global.lives > 0:
		await get_tree().create_timer(0.5).timeout
		ui_hud.show_round()
		player.pre_respawn()
		await get_tree().create_timer(2).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn()
		ui_hud.hide_round()
	else:
		await get_tree().create_timer(0.5).timeout
		if Global.score > Global.high_score:
			Global.high_score = Global.score
			Global.save_config()
			ui_menu.set_saved_values()
		ui_menu.show_menu(ui_menu.MenuFace.GAMEOVER)
 
func _on_asteroid_exploded(pos: Vector2, laser_rotation: float, size: Asteroid.AsteroidSize, points: int):
	hit_audio.play()
	Global.score += points
	ui_hud.update()
	match size:
		Asteroid.AsteroidSize.MEDIUM:
			spawn_asteroid(pos, laser_rotation + randf_range(0, PI / 4), Asteroid.AsteroidSize.SMALL)
			spawn_asteroid(pos, laser_rotation - randf_range(0, PI / 4), Asteroid.AsteroidSize.SMALL)
		Asteroid.AsteroidSize.LARGE:
			spawn_asteroid(pos, laser_rotation + randf_range(0, PI / 4), Asteroid.AsteroidSize.MEDIUM)
			spawn_asteroid(pos, laser_rotation - randf_range(0, PI / 4), Asteroid.AsteroidSize.MEDIUM)

func new_game():
	pass

func spawn_large_asteroids():
	var player_pos: Vector2 = player.global_position
	var screen_size: Vector2 = get_viewport_rect().size
	var pos_array: Array[Vector2] = [Vector2(player_pos)]
	for i in Global.large_asteroids_number:
		var new_pos = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
		var distance_array = pos_array.map(func(pos): return new_pos.distance_squared_to(pos))
		while distance_array.min() < 40000: #200 non squared
			new_pos.x = randf_range(0, screen_size.x)
			new_pos.y = randf_range(0, screen_size.y)
			distance_array = pos_array.map(func(pos): return new_pos.distance_squared_to(pos))
		pos_array.push_back(new_pos)
		spawn_asteroid(new_pos, randf_range(0, 2 * PI), Asteroid.AsteroidSize.LARGE)

func spawn_asteroid(pos: Vector2, new_rotation: float, size: Asteroid.AsteroidSize):
	var asteroid := AsteroidScene.instantiate()
	asteroid.global_position = pos
	asteroid.size = size
	asteroid.rotation = new_rotation
	asteroid.speed_multiplier = Global.asteroid_speed_multiplier
	asteroid.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", asteroid)

func next_round(first_round: bool):
	if !Global.next_round_pause:
		Global.next_round_pause = true
		if !first_round: Global.game_round += 1
		ui_hud.show_round()
		await get_tree().create_timer(2.5).timeout
		ui_hud.hide_round()
		spawn_large_asteroids()
		Global.next_round_pause = false
