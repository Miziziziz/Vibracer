extends Path2D

export var track_color = Color.crimson
export var track_width = 15.0

func _draw():
#	var first = true
#	var last_point : Vector2
#	for p in curve.get_baked_points():
#		if !first:
#			draw_line(last_point, p, track_color, track_width)
#		last_point = p
#		first = false
	draw_polyline(curve.get_baked_points(), track_color, track_width)

