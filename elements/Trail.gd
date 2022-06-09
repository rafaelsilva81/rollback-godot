extends Line2D

var target
var point
var target_path

func _network_spawn(data: Dictionary) -> void: 
	#target_path = data['target_path']
	#target = get_node(target_path)
	var c = Color(data['_color'])
	self.modulate = c
	#connect("addpoint", self, "add_new_point")

#func add_new_point():
	#global_position = Vector2(0,0)
	#global_rotation = 0
	#point = target.global_position
	#add_point(point)
