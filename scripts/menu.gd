class_name UIMenu extends CanvasLayer

enum MenuFace {MAIN, PAUSE, GAMEOVER}

signal change_options()
signal new_game(is_game_over: bool)

@onready var main_menu: Control = $MainMenu
@onready var options_menu: Control = $OptionMenu
@onready var highscore_menu: Control = $HighScoreMenu
@onready var credits_menu: Control = $CreditsMenu
@onready var title_label: Label = $MainMenu/MainVBoxContainer/TitleLabel
@onready var game_button: Button = $MainMenu/MainVBoxContainer/GameButton
@onready var exit_button: Button = $MainMenu/MainVBoxContainer/ExitButton
@onready var difficulty_options: OptionButton = $OptionMenu/OptionsVBoxContainer/DifficultyHBoxContainer/DifficultyOptionButton
@onready var detail_options: OptionButton = $OptionMenu/OptionsVBoxContainer/DetailHBoxContainer/DetailOptionButton
@onready var joypad_container: HBoxContainer = $OptionMenu/OptionsVBoxContainer/JoypadHBoxContainer
@onready var joypad_options: OptionButton = $OptionMenu/OptionsVBoxContainer/JoypadHBoxContainer/JoypadOptionButton
@onready var fullscreen_container: HBoxContainer = $OptionMenu/OptionsVBoxContainer/ScreenHBoxContainer
@onready var fullscreen_check: CheckButton = $OptionMenu/OptionsVBoxContainer/ScreenHBoxContainer/FullScreenCheckButton
@onready var sfx_slider: HSlider = $OptionMenu/OptionsVBoxContainer/SfxHBoxContainer/SfxHSlider
@onready var music_slider: HSlider = $OptionMenu/OptionsVBoxContainer/MusicHBoxContainer/MusicHSlider
@onready var easy_score: Label = $HighScoreMenu/HighScoreVBoxContainer/EasyHBoxContainer/EasyScoreLabel
@onready var normal_score: Label = $HighScoreMenu/HighScoreVBoxContainer/NormalHBoxContainer/NormalScoreLabel
@onready var hard_score: Label = $HighScoreMenu/HighScoreVBoxContainer/HardHBoxContainer/HardScoreLabel
@onready var score_back_button: Button = $HighScoreMenu/HighScoreVBoxContainer/BackButton
@onready var credits_back_button: Button = $CreditsMenu/CreditsVBoxContainer/BackButton

var face: MenuFace = MenuFace.MAIN

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu.visible = false
	options_menu.visible = false
	highscore_menu.visible = false
	credits_menu.visible = false
	if Global.is_mobile:
		fullscreen_container.visible = false
	if Global.is_web:
		exit_button.visible = false
	Input.connect("joy_connection_changed", _on_joy_connection_changed)
	update_joypads()

func _process(_delta: float) -> void:
	if ResourcesPreload.loaded:
		set_process(false)
		main_menu.visible = true
		grab_focus()

func _on_game_button_pressed() -> void:
	match face:
		MenuFace.MAIN: #NEW GAME
			Global.game_started = true
			MusicController.stop_music_immediate(false)
			emit_signal("new_game", false)
		MenuFace.PAUSE: #RESUME
			get_tree().paused = false
			MusicController.stop_music_immediate(false)
			MusicController.play_music(MusicController.Type.GAME, true, false)
		MenuFace.GAMEOVER: #TRY AGAIN
			Global.game_started = true
			MusicController.stop_music_immediate(false)
			emit_signal("new_game", true)
	visible = false
	Global.game_menu = false

func _on_options_button_pressed() -> void:
	main_menu.visible = false
	options_menu.visible = true
	grab_focus()

func _on_high_score_button_pressed() -> void:
	main_menu.visible = false
	highscore_menu.visible = true
	grab_focus()

func _on_credits_button_pressed() -> void:
	main_menu.visible = false
	credits_menu.visible = true
	grab_focus()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_full_screen_check_button_toggled(button_pressed) -> void:
	Global.window_mode = Global.WindowMode.FULLSCREEN if button_pressed else Global.WindowMode.WINDOW
	emit_signal("change_options")

func _on_difficulty_option_button_item_selected(index) -> void:
	Global.difficulty = index

func _on_detail_option_button_item_selected(index) -> void:
	Global.detail = index
	emit_signal("change_options")

func _on_joypad_option_button_item_selected(index) -> void:
	Global.joypad = joypad_options.get_item_id(index)

func _on_sfx_h_slider_value_changed(value) -> void:
	Global.sfx_volume = value
	Global.sfx_volume_db = Util.volume_to_db(value)

func _on_music_h_slider_value_changed(value) -> void:
	Global.music_volume = value
	Global.music_volume_db = Util.volume_to_db(value)
	MusicController.music.volume_db = Global.music_volume_db

func _on_code_button_pressed() -> void:
	OS.shell_open("https://github.com/x7bit")

func _on_music_button_pressed() -> void:
	OS.shell_open("https://whitebataudio.com/")

func _on_thanks_button_pressed() -> void:
	OS.shell_open("https://www.youtube.com/@KaanAlpar")

func _on_back_button_pressed() -> void:
	if options_menu.visible: Global.save_config()
	main_menu.visible = true
	options_menu.visible = false
	highscore_menu.visible = false
	credits_menu.visible = false
	grab_focus()

func _on_joy_connection_changed(joypad: int, connected: bool) -> void:
	update_joypads()
	if joypad == Global.joypad && !connected:
		joypad_options.selected = joypad_options.get_item_index(Global.NO_JOYPAD)

func update() -> void:
	fullscreen_check.button_pressed = Global.window_mode == Global.WindowMode.FULLSCREEN
	difficulty_options.selected = Global.difficulty
	detail_options.selected = Global.detail
	joypad_options.selected = joypad_options.get_item_index(Global.joypad)
	sfx_slider.value = Global.sfx_volume
	music_slider.value = Global.music_volume
	easy_score.text = str(Global.high_scores[Global.Difficulty.EASY])
	normal_score.text = str(Global.high_scores[Global.Difficulty.NORMAL])
	hard_score.text = str(Global.high_scores[Global.Difficulty.HARD])

func show_menu(new_face: MenuFace) -> void:
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
	Global.game_menu = true
	grab_focus()

func grab_focus() -> void:
	if options_menu.visible:
		difficulty_options.grab_focus()
	elif highscore_menu.visible:
		score_back_button.grab_focus()
	elif credits_menu.visible:
		credits_back_button.grab_focus()
	else:
		game_button.grab_focus()

func update_joypads() -> void:
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		joypad_container.visible = true
		joypad_options.clear()
		joypad_options.add_item("None", Global.NO_JOYPAD)
		for joypad in joypads:
			joypad_options.add_item(Input.get_joy_name(joypad), joypad)
		joypad_options.selected = joypad_options.get_item_index(Global.joypad)
	else:
		joypad_container.visible = false
