class_name SfxStreamPlayer extends AudioStreamPlayer

var sfx: SfxController.Sfx
var id: int
var is_loop: bool

func set_values(_sfx: SfxController.Sfx, _id: int, _is_loop: bool) -> void:
	sfx = _sfx
	id = _id
	is_loop = _is_loop
