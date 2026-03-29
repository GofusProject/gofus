class_name AStar2DExtended
extends AStar2D

enum Heuristic {
	HEURISTIC_EUCLIDEAN = 0,
	HEURISTIC_MANHATTAN = 1,
	HEURISTIC_OCTILE    = 2,
	HEURISTIC_CHEBYSHEV = 3,
}

var heuristic: Heuristic = Heuristic.HEURISTIC_EUCLIDEAN


func _estimate_cost(from_id: int, to_id: int) -> float:
	return _apply_heuristic(from_id, to_id)


func _compute_cost(from_id: int, to_id: int) -> float:
	return _apply_heuristic(from_id, to_id)


func _apply_heuristic(from_id: int, to_id: int) -> float:
	var from : Vector2 = get_point_position(from_id)
	var to   : Vector2 = get_point_position(to_id)
	var dx   : float = absf(to.x - from.x)
	var dy   : float = absf(to.y - from.y)

	match heuristic:
		Heuristic.HEURISTIC_EUCLIDEAN:
			return sqrt(dx * dx + dy * dy)

		Heuristic.HEURISTIC_MANHATTAN:
			return dx + dy

		Heuristic.HEURISTIC_OCTILE:
			var f := sqrt(2.0) - 1.0
			return f * minf(dx, dy) + maxf(dx, dy)

		Heuristic.HEURISTIC_CHEBYSHEV:
			return maxf(dx, dy)

		_:
			# Default: HEURISTIC_EUCLIDEAN
			return sqrt(dx * dx + dy * dy)