extends Sprite

onready var paint_brush = $PaintBrush

func _network_spawn_preprocess(data: Dictionary) -> Dictionary:
	var c = data['_color'].to_html(false)
	return {
		_color = c
	}
	
func _network_spawn_process(data: Dictionary) -> void:
	var c = Color(data['_color'])
	print(c)
	paint_brush.modulate = c

