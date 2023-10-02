extends Node

func get_poly_rect(poly: PackedVector2Array, scale: Vector2) -> Rect2:
	if poly.size() == 0:
		return Rect2(0.0, 0.0, 0.0, 0.0)
	
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
