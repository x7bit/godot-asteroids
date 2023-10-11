extends Node

enum Sfx {LASER, HIT, BOUNCE, DIE, THRUST}
enum Mode {PLAY, STOP}

const AUDIOS = {
	Sfx.LASER: preload("res://assets/audio/blaster.ogg"),
	Sfx.HIT: preload("res://assets/audio/hit.ogg"),
	Sfx.BOUNCE: preload("res://assets/audio/bounce.ogg"),
	Sfx.DIE: preload("res://assets/audio/explosion.ogg"),
	Sfx.THRUST: preload("res://assets/audio/thrust.ogg"),
}
const MAX_POOL_SIZE := 12

var used_player_pool: Array[SfxStreamPlayer] = []
var free_player_pool: Array[SfxStreamPlayer] = []
var player_idx: int = 0 #for when there are no free audios

func _ready():
	for i in MAX_POOL_SIZE:
		var player := SfxStreamPlayer.new()
		add_child(player)
		free_player_pool.push_back(player)

func _process(_delta: float):
	var playing_players: Array[SfxStreamPlayer] = []
	var not_playing_players: Array[SfxStreamPlayer] = []
	for player in used_player_pool:
		if player.is_playing():
			playing_players.push_back(player)
		else:
			not_playing_players.push_back(player)
	used_player_pool = playing_players
	free_player_pool += not_playing_players

func play(sfx: Sfx, id: int = -1):
	if Global.game_menu: return
	var is_loop = _is_loop(sfx)
	var player = _get_player(Mode.PLAY, sfx, id, is_loop)
	player.volume_db = Global.sfx_volume_db
	if is_loop:
		if !player.is_playing(): player.play()
	else:
		player.play()

func play_in_unique_player(sfx: Sfx, id: int = -1) -> void:
	if Global.game_menu: return
	var is_loop = _is_loop(sfx) 
	var player = _get_player_in_unique_player(Mode.PLAY, sfx, id, is_loop)
	player.volume_db = Global.sfx_volume_db
	if is_loop:
		if !player.is_playing(): player.play()
	else:
		player.play()

func stop_in_unique_player(sfx: Sfx, id: int = -1):
	if Global.game_menu: return
	var is_loop = _is_loop(sfx)
	var player = _get_player_in_unique_player(Mode.STOP, sfx, id, is_loop)
	if player != null:
		player.stop()

func _get_player(mode: Mode, sfx: Sfx, id: int, is_loop: bool) -> SfxStreamPlayer:
	if id >= 0:
		for player in used_player_pool:
			if player.sfx == sfx && player.id == id:
				return player
	return null if mode == Mode.STOP else _get_free_player(sfx, id, is_loop)

func _get_player_in_unique_player(mode: Mode, sfx: Sfx, id: int, is_loop: bool) -> SfxStreamPlayer:
	if id >= 0:
		for player in used_player_pool:
			if player.sfx == sfx && player.id == id:
				return player
	else:
		for player in used_player_pool:
			if player.sfx == sfx:
				return player
	return null if mode == Mode.STOP else _get_free_player(sfx, id, is_loop)

func _get_free_player(sfx: Sfx, id: int, is_loop: bool) -> SfxStreamPlayer:
	if free_player_pool.size() > 0:
		var player = free_player_pool.pop_back()
		player.stream = AUDIOS[sfx]
		player.set_values(sfx, id, is_loop)
		player_idx = 0
		used_player_pool.push_back(player)
		return player
	else:
		var new_player = used_player_pool[player_idx]
		new_player.stop()
		new_player.stream = AUDIOS[sfx]
		new_player.set_values(sfx, id, is_loop)
		player_idx = (player_idx + 1) % MAX_POOL_SIZE
		return new_player

func _is_loop(sfx: Sfx) -> bool:
	match sfx:
		Sfx.THRUST:
			return true
		_:
			return false
