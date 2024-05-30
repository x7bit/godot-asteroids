extends Node

enum ScreenBorder {UP, DOWN, LEFT, RIGHT}

const INT_MIN: int = -(1 << 63)
const INT_MAX: int = (1 << 63) - 1
const TWO_PI: float = PI * 2.0
const HALF_PI: float = PI / 2.0
const THREE_HALF_PI: float = 3.0 * HALF_PI

func volume_to_db(value: float) -> float:
	if value <= 0.0001: return -80.0
	return linear_to_db(value)

func get_poly_rect(poly: PackedVector2Array, scale: Vector2) -> Rect2:
	if poly.size() == 0: return Rect2(0.0, 0.0, 0.0, 0.0)
	var min_x := 2e30
	var max_x := 0.0
	var min_y := 2e30
	var max_y := 0.0
	for vec in poly:
		var vec_scaled := vec * scale
		if (vec_scaled.x < min_x):
			min_x = vec_scaled.x
		if (vec_scaled.x > max_x):
			max_x = vec_scaled.x
		if (vec_scaled.y < min_y):
			min_y = vec_scaled.y
		if (vec_scaled.y > max_y):
			max_y = vec_scaled.y
	return Rect2(min_x, min_y, abs(min_x - max_x), abs(min_y - max_y))

func get_rotation_based_up_vector(vector: Vector2) -> float:
	return -vector.angle_to(Vector2.UP)

func get_explosion_rotation(laser: Laser, asteroid: Asteroid) -> float:
	if asteroid.size == Asteroid.AsteroidSize.SMALL: return 0.0
	var laser_vector = Vector2.UP.rotated(laser.rotation) * Laser.SPEED
	var asteroid_vector = Vector2.UP.rotated(asteroid.move_angle) * asteroid.linear_velocity.length() * asteroid.mass_multiplier
	return get_rotation_based_up_vector(laser_vector + asteroid_vector)

func is_in_screen_visible(sprite_position: Vector2, screen_size: Vector2) -> bool:
	var is_in_up = sprite_position.y >= 0
	var is_in_down = sprite_position.y <= screen_size.y
	var is_in_left = sprite_position.x >= 0
	var is_in_right = sprite_position.x <= screen_size.x
	return is_in_up && is_in_down && is_in_left && is_in_right

func get_min_index_array(input_array: Array) -> Array[int]:
	var min_value: int = INT_MAX
	var min_idx_array: Array[int] = []
	for idx in input_array.size():
		var value = input_array[idx]
		if value < min_value:
			min_value = value
			min_idx_array.clear()
			min_idx_array.push_back(idx)
		elif value == min_value:
			min_idx_array.push_back(idx)
	return min_idx_array
