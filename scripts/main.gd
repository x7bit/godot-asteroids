extends Node2D

@onready var menu: UIMenu = $Menu
@onready var game: Game = $Game
@onready var starfield: Starfield = $Starfield

func _ready():
	Global.init(true)
	starfield.set_starfield()
	menu.update()
	_on_menu_change_options()
	game.visible = false
	menu.show_menu(menu.MenuFace.MAIN)
	MusicController.play_music_immediate(MusicController.Type.INTRO, false, false)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("pause") && Global.lives > 0:
		get_tree().paused = true
		menu.show_menu(menu.MenuFace.PAUSE)
		MusicController.stop_music_immediate(false)
		MusicController.play_music(MusicController.Type.INTRO, true, true)

func _on_game_over() -> void:
	MusicController.stop_music_immediate(true)
	await get_tree().create_timer(0.5).timeout
	if Global.score > Global.high_score:
		Global.high_score = Global.score
		Global.save_config()
		menu.update()
	MusicController.play_music(MusicController.Type.INTRO, true, true)
	menu.show_menu(menu.MenuFace.GAMEOVER)

func _on_menu_new_game(is_game_over: bool) -> void:
	menu.visible = false
	game.visible = true
	game.new_game(is_game_over)

func _on_menu_change_options() -> void:
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
	starfield.set_starfield()
