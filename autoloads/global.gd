extends Node

const CONFIG_FILE := "user://asteroids.cfg"

enum WindowMode {WINDOW, FULLSCREEN}
enum Detail {LOW, MEDIUM, HIGH}
enum Difficulty {EASY, NORMAL, HARD}

var window_mode := WindowMode.WINDOW
var difficulty := Difficulty.NORMAL
var detail := Detail.HIGH
var sfx_volume: float = 1.0
var sfx_volume_db: float = 0.0
var music_volume: float = 0.8
var music_volume_db: float = linear_to_db(0.8)
var lives: int = 3
var score: int = 0
var game_round: int = 0
var game_started: bool = false
var game_menu: bool = true
var next_round_pause: bool = false
var high_scores = { Difficulty.EASY: 0, Difficulty.NORMAL: 0, Difficulty.HARD: 0 }

var high_score: int:
	get:
		return high_scores[difficulty]
	set(value):
		high_scores[difficulty] = value

var asteroid_speed_multiplier: float:
	get:
		match difficulty:
			Difficulty.EASY:
				return game_round * 0.1 + 0.8
			Difficulty.HARD:
				return game_round * 0.3 + 1.2
			_: #NORMAL
				return game_round * 0.2 + 1.0

var large_asteroids_number: int:
	get:
		match difficulty:
			Difficulty.EASY:
				return 4
			Difficulty.HARD:
				return 6
			_: #NORMAL
				return 5

var game_round_label: String:
	get:
		return "ROUND: " + str(game_round + 1)

func init():
	lives = 3
	score = 0
	game_round = 0
	load_config()

func load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err != OK:
		window_mode = WindowMode.WINDOW
		difficulty = Difficulty.NORMAL
		detail = Detail.HIGH
		sfx_volume = 1.0
		sfx_volume_db = 0.0
		music_volume = 0.8
		music_volume_db = Util.volume_to_db(music_volume)
		high_scores[Difficulty.EASY] = 0
		high_scores[Difficulty.NORMAL] = 0
		high_scores[Difficulty.HARD] = 0
		save_config()
	else:
		window_mode = config.get_value("options", "window_mode", WindowMode.WINDOW)
		difficulty = config.get_value("options", "difficulty", Difficulty.NORMAL)
		detail = config.get_value("options", "detail", Detail.HIGH)
		sfx_volume = config.get_value("options", "sfx_volume", 1.0)
		sfx_volume_db = Util.volume_to_db(sfx_volume)
		music_volume = config.get_value("options", "music_volume", 0.8)
		music_volume_db = Util.volume_to_db(music_volume)
		high_scores[Difficulty.EASY] = config.get_value("highscore", "easy", 0)
		high_scores[Difficulty.NORMAL] = config.get_value("highscore", "normal", 0)
		high_scores[Difficulty.HARD] = config.get_value("highscore", "hard", 0)

func save_config():
	var config = ConfigFile.new()
	config.set_value("options", "window_mode", window_mode)
	config.set_value("options", "difficulty", difficulty)
	config.set_value("options", "detail", detail)
	config.set_value("options", "sfx_volume", sfx_volume)
	config.set_value("options", "music_volume", music_volume)
	config.set_value("highscore", "easy", high_scores[Difficulty.EASY])
	config.set_value("highscore", "normal", high_scores[Difficulty.NORMAL])
	config.set_value("highscore", "hard", high_scores[Difficulty.HARD])
	config.save(CONFIG_FILE)
