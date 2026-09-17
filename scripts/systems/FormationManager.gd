extends Node

enum FormationType { PHALANX, WEDGE, SKIRMISH_LINE, SQUARE, COLUMN }

func get_formation_slots(form_type: FormationType, count: int, center_pos: Vector3, facing_dir: Vector3, spacing: float = 2.4) -> Array[Vector3]:
	var slots: Array[Vector3] = []
	if count <= 0:
		return slots
	
	facing_dir.y = 0.0
	if facing_dir.length_squared() < 0.001:
		facing_dir = Vector3.FORWARD
	facing_dir = facing_dir.normalized()
	
	var right_dir = Vector3.UP.cross(facing_dir).normalized()
	
	match form_type:
		FormationType.PHALANX:
			var cols = min(count, 4)
			var rows = int(ceil(float(count) / float(cols)))
			for i in range(count):
				var r = i / cols
				var c = i % cols
				var x_off = (c - (cols - 1) * 0.5) * spacing
				var z_off = -r * spacing
				slots.append(center_pos + (right_dir * x_off) + (facing_dir * z_off))
		
		FormationType.WEDGE:
			var current_row = 0
			var in_row = 0
			for i in range(count):
				var x_off = (in_row - current_row * 0.5) * spacing
				var z_off = -current_row * spacing
				slots.append(center_pos + (right_dir * x_off) + (facing_dir * z_off))
				in_row += 1
				if in_row > current_row:
					current_row += 1
					in_row = 0
		
		FormationType.SKIRMISH_LINE:
			for i in range(count):
				var x_off = (i - (count - 1) * 0.5) * (spacing * 1.8)
				slots.append(center_pos + (right_dir * x_off))
		
		_:
			for i in range(count):
				slots.append(center_pos + right_dir * (i * spacing))
	
	return slots
