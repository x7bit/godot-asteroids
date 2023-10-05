extends Node

enum Type{INTRO, GAME}
enum Command{PlAY, STOP}
enum Playing{INTRO, GAME, NONE}

const INTRO_URL: String = "res://assets/audio/music/intro_music.ogg"
const GAME_URLS: Array[String] = [
	"res://assets/audio/music/game1_music.ogg",
	"res://assets/audio/music/game2_music.ogg"
]

@onready var music: AudioStreamPlayer = $MusicStreamPlayer

var game_index: int = 0
var game_count: Array[int] = [0, 0]
var intro_seek: float = 0.0
var game_seek: float = 0.0
var stack: Array[Dictionary] = []
var playing: Playing = Playing.NONE
var fading: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_index = randi_range(0, game_count.size() - 1)

func _process(delta: float):
	if stack.size() == 0: return
	var command = stack[0]["command"]
	var fade = stack[0]["fade"]
	if command == Command.PlAY:
		var type = stack[0]["type"]
		var resume = stack[0]["resume"]
		var stream = _get_music_stream(type)
		var seek = _get_music_seek(type, resume)
		if fade:
			if fading:
				var new_volume_linear = db_to_linear(music.volume_db) + delta * 0.7
				var new_volume_db = linear_to_db(new_volume_linear)
				if new_volume_db < Global.music_volume_db:
					music.volume_db = new_volume_db
				else:
					music.volume_db = Global.music_volume_db
					stack.remove_at(0)
					fading = false
			else:
				music.stream = stream
				music.volume_db = -80.0
				music.play(seek)
				playing = type
				fading = true
		else:
			music.stream = stream
			music.volume_db = Global.music_volume_db
			music.play(seek)
			stack.remove_at(0)
			playing = type
			fading = false
	else: #STOP
		if fade:
			if fading:
				var new_volume_linear = db_to_linear(music.volume_db) - delta * 0.7
				var new_volume_db = linear_to_db(new_volume_linear)
				if new_volume_db > -80.0:
					music.volume_db = new_volume_db
				else:
					music.stop()
					music.volume_db = Global.music_volume_db
					stack.remove_at(0)
					playing = Playing.NONE
					fading = false
			else:
				_set_music_seek()
				fading = true
		else:
			_set_music_seek()
			music.stop()
			music.volume_db = Global.music_volume_db
			stack.remove_at(0)
			playing = Playing.NONE
			fading = false

func play_music(type: Type, resume: bool, fade: bool) -> void:
	var music_item = { "command": Command.PlAY, "type": type, "resume": resume, "fade": fade }
	stack.push_back(music_item)

func play_music_immediate(type: Type, resume: bool, fade: bool) -> void:
	stack.clear()
	play_music(type, resume, fade)

func stop_music(fade: bool) -> void:
	var music_item = { "command": Command.STOP, "fade": fade }
	stack.push_back(music_item)

func stop_music_immediate(fade: bool) -> void:
	stack.clear()
	stop_music(fade)

func set_new_game_music() -> void:
	var min_idx_array = Util.get_min_index_array(game_count)
	var old_game_index = game_index
	while game_index == old_game_index:
		game_index = min_idx_array[randi_range(0, min_idx_array.size() - 1)]
	game_count[game_index] += 1

func _get_music_stream(type: Type) -> AudioStream:
	if type == Type.INTRO:
		return load(INTRO_URL)
	else:
		return load(GAME_URLS[game_index])

func _get_music_seek(type: Type, resume: bool) -> float:
	if resume:
		return intro_seek if type == Type.INTRO else game_seek
	else:
		return 0.0

func _set_music_seek() -> void:
	var seek = music.get_playback_position()
	match playing:
		Playing.INTRO:
			intro_seek = seek
		Playing.GAME:
			game_seek = seek
