extends Node

enum Type{INTRO, GAME}
enum Command{PlAY, STOP}
enum Playing{INTRO, GAME, NONE}

@onready var music: AudioStreamPlayer = $MusicStreamPlayer

var intro_stream: AudioStream = load("res://assets/audio/intro_music.ogg")
var game_stream: AudioStream = load("res://assets/audio/game_music.ogg")

var intro_seek: float = 0.0
var game_seek: float = 0.0
var stack: Array[Dictionary] = []
var playing: Playing = Playing.NONE
var fading: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

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

func play_music(type: Type, resume: bool, fade: bool):
	var music_item = { "command": Command.PlAY, "type": type, "resume": resume, "fade": fade }
	stack.push_back(music_item)

func play_music_immediate(type: Type, resume: bool, fade: bool):
	stack.clear()
	play_music(type, resume, fade)

func stop_music(fade: bool):
	var music_item = { "command": Command.STOP, "fade": fade }
	stack.push_back(music_item)

func stop_music_immediate(fade: bool):
	stack.clear()
	stop_music(fade)

func _get_music_stream(type: Type):
	return intro_stream if type == Type.INTRO else game_stream

func _get_music_seek(type: Type, resume: bool):
	if resume:
		return intro_seek if type == Type.INTRO else game_seek
	else:
		return 0.0

func _set_music_seek():
	var seek = music.get_playback_position()
	match playing:
		Playing.INTRO:
			intro_seek = seek
		Playing.GAME:
			game_seek = seek
