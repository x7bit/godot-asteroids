class_name UIMenu extends CanvasLayer

enum MenuFace {MAIN, PAUSE, GAMEOVER}

signal change_options()
signal new_game(is_game_over: bool)

@onready var main_menu: Control = $MainMenu
@onready var main_container: BoxContainer = $MainMenu/MainVBoxContainer
@onready var options_menu: Control = $OptionMenu
@onready var options_container: BoxContainer = $OptionMenu/OptionsVBoxContainer
@onready var highscore_menu: Control = $HighScoreMenu
@onready var highscore_container: BoxContainer = $HighScoreMenu/HighScoreVBoxContainer
@onready var credits_menu: Control = $CreditsMenu
@onready var credits_container: BoxContainer = $CreditsMenu/CreditsVBoxContainer
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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu.visible = true
	options_menu.visible = false
	highscore_menu.visible = false
	credits_menu.visible = false
	if Global.is_mobile:
		fullscreen_check.visible = false

func _process(_delta: float) -> void:
	if Global.game_menu:
		if Input.is_action_just_pressed("move_forward"):
			move_vertically(true)
		if Input.is_action_just_pressed("move_backward"):
			move_vertically(false)
		if Input.is_action_pressed("rotate_left"):
			move_horizontally(true)
		if Input.is_action_pressed("rotate_right"):
			move_horizontally(false)

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

func _on_high_score_button_pressed() -> void:
	main_menu.visible = false
	highscore_menu.visible = true

func _on_credits_button_pressed() -> void:
	main_menu.visible = false
	credits_menu.visible = true

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

func update() -> void:
	fullscreen_check.button_pressed = Global.window_mode == Global.WindowMode.FULLSCREEN
	difficulty_options.selected = Global.difficulty
	detail_options.selected = Global.detail
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

func move_vertically(up: bool) -> void:
	var container: BoxContainer = get_container()
	var control_array: Array[Control] = Util.get_interactive_control_array(container)
	if control_array.size() > 0:
		var focus_idx: int = Util.get_focus_index(control_array)
		var offset_idx = -1 if up else 1
		if focus_idx != -1 && control_array[focus_idx] is OptionButton:
			var option_popup: PopupMenu = control_array[focus_idx].get_popup()
			if option_popup.visible:
				var new_selected_idx: int = (option_popup.get_focused_item() + offset_idx) % option_popup.item_count
				new_selected_idx = option_popup.item_count - 1 if new_selected_idx == -1 else new_selected_idx
				option_popup.set_focused_item(new_selected_idx)
				option_popup.emit_signal("index_pressed", new_selected_idx)
				return
		var new_idx: int = 0 if focus_idx == -1 else (focus_idx + offset_idx) % control_array.size()
		control_array[new_idx].grab_focus()

func move_horizontally(left: bool) -> void:
	var container: BoxContainer = get_container()
	var control_array: Array[Control] = Util.get_interactive_control_array(container)
	if control_array.size() > 0:
		var focus_idx: int = Util.get_focus_index(control_array)
		var offset_val: float = -0.002 if left else 0.002
		if focus_idx != -1 && control_array[focus_idx] is Slider:
			var slider = control_array[focus_idx]
			var new_val: float = slider.value + offset_val
			new_val = maxf(new_val, 0)
			new_val = minf(new_val, 1)
			slider.value = new_val

func get_container() -> BoxContainer:
	if options_menu.visible:
		return options_container
	elif highscore_menu.visible:
		return highscore_container
	elif credits_menu.visible:
		return credits_container
	else:
		return main_container
