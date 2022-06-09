extends Sprite

func _network_spawn(data: Dictionary) -> void:
	var c = Color(data['_color'])
	self.modulate = c

