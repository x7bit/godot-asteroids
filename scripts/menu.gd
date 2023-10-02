extends Control

enum MenuFace{MAIN, PAUSE, GAMEOVER}

signal change_options()

@onready var main_menu: Control = $MainMenu
@onready var options_menu: Control = $OptionMenu
@onready var highscore_menu: Control = $HighScoreMenu
@onready var title_label: Label = $MainMenu/MainVBoxContainer/TitleLabel
@onready var game_button: Button = $MainMenu/MainVBoxContainer/GameButton
@onready var fullscreen_check: CheckButton = $OptionMenu/OptionsVBoxContainer/FullScreenCheckButton
@onready var difficulty_options: OptionButton = $OptionMenu/OptionsVBoxContainer/DifficultyHBoxContainer/DifficultyOptionButton
@onready var detail_options: OptionButton = $OptionMenu/OptionsVBoxContainer/DetailHBoxContainer/DetailOptionButton
@onready var easy_score: Label = $HighScoreMenu/HighScoreVBoxContainer/EasyHBoxContainer/EasyScoreLabel
@onready var normal_score: Label = $HighScoreMenu/HighScoreVBoxContainer/NormalHBoxContainer/NormalScoreLabel
@onready var hard_score: Label = $HighScoreMenu/HighScoreVBoxContainer/HardHBoxContainer/HardScoreLabel

var face: MenuFace = MenuFace.MAIN

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu.visible = true
	options_menu.visible = false
	highscore_menu.visible = false

func _process(_delta: float):
	pass

func _on_game_button_pressed():
	match face:
		MenuFace.MAIN:
			Global.game_started = true
			get_tree().reload_current_scene()
		MenuFace.PAUSE:
			get_tree().paused = false
		MenuFace.GAMEOVER:
			Global.game_started = true
			get_tree().reload_current_scene()
	visible = false

func _on_options_button_pressed():
	main_menu.visible = false
	options_menu.visible = true

func _on_high_score_button_pressed():
	main_menu.visible = false
	highscore_menu.visible = true

func _on_exit_button_pressed():
	get_tree().quit()

func _on_full_screen_check_button_toggled(button_pressed):
	Global.window_mode = Global.WindowMode.FULLSCREEN if button_pressed else Global.WindowMode.WINDOW
	Global.save_config()
	emit_signal("change_options")

func _on_difficulty_option_button_item_selected(index):
	Global.difficulty = index
	Global.save_config()

func _on_option_button_item_selected(index):
	Global.detail = index
	Global.save_config()
	emit_signal("change_options")

func _on_back_button_pressed():
	main_menu.visible = true
	options_menu.visible = false
	highscore_menu.visible = false

func update():
	fullscreen_check.button_pressed = Global.window_mode == Global.WindowMode.FULLSCREEN
	difficulty_options.selected = Global.difficulty
	detail_options.selected = Global.detail
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
