class_name UIMenu extends Control

enum MenuFace{MAIN, PAUSE, GAMEOVER}

signal change_options()

@onready var main_menu: Control = $MainMenu
@onready var options_menu: Control = $OptionMenu
@onready var highscore_menu: Control = $HighScoreMenu
@onready var credits_menu: Control = $CreditsMenu
@onready var title_label: Label = $MainMenu/MainVBoxContainer/TitleLabel
@onready var game_button: Button = $MainMenu/MainVBoxContainer/GameButton
@onready var fullscreen_check: CheckButton = $OptionMenu/OptionsVBoxContainer/FullScreenCheckButton
@onready var difficulty_options: OptionButton = $OptionMenu/OptionsVBoxContainer/DifficultyHBoxContainer/DifficultyOptionButton
@onready var detail_options: OptionButton = $OptionMenu/OptionsVBoxContainer/DetailHBoxContainer/DetailOptionButton
@onready var sfx_slider: HSlider = $OptionMenu/OptionsVBoxContainer/SfxHBoxContainer/SfxHSlider
@onready var music_slider: HSlider = $OptionMenu/OptionsVBoxContainer/MusicHBoxContainer/MusicHSlider
@onready var easy_score: Label = $HighScoreMenu/HighScoreVBoxContainer/EasyHBoxContainer/EasyScoreLabel
@onready var normal_score: Label = $HighScoreMenu/HighScoreVBoxContainer/NormalHBoxContainer/NormalScoreLabel
@onready var hard_score: Label = $HighScoreMenu/HighScoreVBoxContainer/HardHBoxContainer/HardScoreLabel

var face: MenuFace = MenuFace.MAIN

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu.visible = true
	options_menu.visible = false
	highscore_menu.visible = false
	credits_menu.visible = false

func _process(_delta: float):
	pass

func _on_game_button_pressed():
	match face:
		MenuFace.MAIN: #NEW GAME
			Global.game_started = true
			MusicController.stop_music_immediate(false)
			get_tree().reload_current_scene()
		MenuFace.PAUSE: #RESUME
			get_tree().paused = false
			MusicController.stop_music_immediate(false)
			MusicController.play_music(MusicController.Type.GAME, true, false)
		MenuFace.GAMEOVER: #TRY AGAIN
			Global.game_started = true
			MusicController.stop_music_immediate(false)
			get_tree().reload_current_scene()
	visible = false

func _on_options_button_pressed():
	main_menu.visible = false
	options_menu.visible = true

func _on_high_score_button_pressed():
	main_menu.visible = false
	highscore_menu.visible = true

func _on_credits_button_pressed():
	main_menu.visible = false
	credits_menu.visible = true

func _on_exit_button_pressed():
	get_tree().quit()

func _on_full_screen_check_button_toggled(button_pressed):
	Global.window_mode = Global.WindowMode.FULLSCREEN if button_pressed else Global.WindowMode.WINDOW
	emit_signal("change_options")

func _on_difficulty_option_button_item_selected(index):
	Global.difficulty = index

func _on_option_button_item_selected(index):
	Global.detail = index
	emit_signal("change_options")

func _on_sfx_h_slider_value_changed(value):
	Global.sfx_volume = value
	Global.sfx_volume_db = Util.volume_to_db(value)
	emit_signal("change_options")

func _on_music_h_slider_value_changed(value):
	Global.music_volume = value
	Global.music_volume_db = Util.volume_to_db(value)
	MusicController.music.volume_db = Global.music_volume_db

func _on_code_button_pressed():
	OS.shell_open("https://github.com/x7bit")

func _on_music_button_pressed():
	OS.shell_open("https://whitebataudio.com/")

func _on_thanks_button_pressed():
	OS.shell_open("https://www.youtube.com/@KaanAlpar")

func _on_back_button_pressed():
	if options_menu.visible: Global.save_config()
	main_menu.visible = true
	options_menu.visible = false
	highscore_menu.visible = false
	credits_menu.visible = false

func update():
	fullscreen_check.button_pressed = Global.window_mode == Global.WindowMode.FULLSCREEN
	difficulty_options.selected = Global.difficulty
	detail_options.selected = Global.detail
	sfx_slider.value = Global.sfx_volume
	music_slider.value = Global.music_volume
	easy_score.text = str(Global.high_scores[Global.Difficulty.EASY])
	normal_score.text = str(Global.high_scores[Global.Difficulty.NORMAL])
	hard_score.text = str(Global.high_scores[Global.Difficulty.HARD])

func show_menu(new_face: MenuFace):
	match new_face:
		MenuFace.MAIN:
			title_label.text = "ASTEROIDS"
			game_button.text = "NEW GAME"
			difficulty_options.disabled = false
		MenuFace.PAUSE:
			title_label.text = "PAUSE"
			game_button.text = "RESUME"
			difficulty_options.disabled = true
		MenuFace.GAMEOVER:
			title_label.text = "GAME OVER"
			game_button.text = "TRY AGAIN"
			difficulty_options.disabled = false
	face = new_face
	visible = true
