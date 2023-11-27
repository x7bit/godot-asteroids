class_name Indicator extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var fixed_position: Vector2 = Vector2.ZERO
var parent_move_angle: float = 0.0
var alfa: float = 1.0

var radius: float:
	get:
		return sprite.texture.get_width() * get_parent().scale.x * scale.x / 2.0

var parent_position: Vector2:
	get:
		return get_parent().global_position

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	if Util.is_in_screen_visible(parent_position, screen_size):
		fade_out(delta)
	else:
		var new_position: Vector2 = get_position_to_parent(screen_size)
		if new_position == Vector2.ZERO:
			fade_out(delta)
		else:
			alfa = 1.0
			modulate.a = alfa
			global_position = new_position
			visible = true

func fade_out(delta: float) -> void:
	if visible:
		if alfa > 0.0:
			if alfa == 1.0:
				fixed_position = global_position
			else:
				global_position = fixed_position
			alfa = maxf(alfa - (3.0 * delta), 0.0)
			modulate.a = alfa
		else:
			visible = false

func get_position_to_parent(screen_size: Vector2) -> Vector2:
	var move_angle = wrapf(parent_move_angle, 0, 2 * PI)
	var margin: float = radius + 4.0
	var x: float = margin
	var y: float = margin
	if parent_position.y < 0: #UP
		if move_angle > Util.HALF_PI && move_angle < Util.THREE_HALF_PI:
			return Vector2.ZERO
		x = parent_position.x
		y = screen_size.y - margin
	elif parent_position.y > screen_size.y: #DOWN
		if move_angle < Util.HALF_PI || move_angle > Util.THREE_HALF_PI:
			return Vector2.ZERO
		x = parent_position.x
	if parent_position.x < 0: #LEFT
		if move_angle > 0 && move_angle < PI:
			return Vector2.ZERO
		x = screen_size.x - margin
		y = parent_position.y
	elif parent_position.x > screen_size.x: #RIGHT
		if move_angle < Util.TWO_PI && move_angle > PI:
			return Vector2.ZERO
		y = parent_position.y
	x = clampf(x, margin, screen_size.x - margin)
	y = clampf(y, margin, screen_size.y - margin)
	return Vector2(x, y)
