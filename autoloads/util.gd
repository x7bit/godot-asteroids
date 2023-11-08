extends Node

const INT_MIN: int = -(1 << 63)
const INT_MAX: int = (1 << 63) - 1

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
	var asteroid_vector = Vector2.UP.rotated(asteroid.move_rotation) * asteroid.speed * asteroid.mass_multiplier
	return get_rotation_based_up_vector(laser_vector + asteroid_vector)

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

func get_focus_index(control_array: Array[Control]) -> int:
	for idx in control_array.size():
		var control: Control = control_array[idx]
		if control.has_focus():
			return idx
	return -1

func get_interactive_control_array(container: BoxContainer) -> Array[Control]:
	var clickable_array: Array[Control] = []
	for child in container.get_children():
		if child is BoxContainer:
			for grandchild in child.get_children():
				if grandchild is Control && is_control_interactive(grandchild):
					clickable_array.push_back(grandchild)
		elif child is Control && is_control_interactive(child):
			clickable_array.push_back(child)
	return clickable_array

func is_control_interactive(control: Control) -> bool:
	return control is Button || control is Slider
