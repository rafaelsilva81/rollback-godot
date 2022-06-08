extends SGArea2D

onready var collision_shape = $SGCollisionShape2D
onready var P1Label = get_tree().get_root().get_node("Main/Background/P1Label")
onready var P2Label = get_tree().get_root().get_node("Main/Background/P2Label")
onready var Reset = get_tree().get_root().get_node("Main/ConnectionCanvas/ResetButton")
var movement_x := SGFixed.from_int(3)
var movement_y := SGFixed.from_int(0)
var MOVEMENT_SPEED := SGFixed.from_int(5)
var RADIUS := SGFixed.from_int(25)

#onready var radius := collision_shape.get_shape().extents_x

var vector : SGFixedVector2
var pos : SGFixedVector2
var last_overlapping_bodies: Array
var initial_position : Vector2

func _network_spawn(data: Dictionary) -> void:
	global_position = data['position']
	initial_position = global_position
	fixed_position = SGFixed.from_float_vector2(global_position)
	
func _physics_process(delta):
	vector = SGFixed.vector2(movement_x, movement_y)
	vector.imul(MOVEMENT_SPEED)
	fixed_position.iadd(vector)
	sync_to_physics_engine()
	var overlapping_bodies = get_overlapping_bodies()
	
	var overlapping_areas = get_overlapping_areas()
	for body in overlapping_areas:
		if (body.name == "P1Point"):
			var new_score = int(P1Label.text) + 1
			P1Label.text = str(new_score)
			if(new_score >= 10):
				Reset.emit_signal("pressed")
			fixed_position = SGFixed.from_float_vector2(initial_position)
		elif(body.name == "P2Point"):
			var new_score = int(P2Label.text) + 1
			P2Label.text = str(new_score)
			if(new_score >= 10):
				Reset.emit_signal("pressed")
			fixed_position = SGFixed.from_float_vector2(initial_position)
	for body in overlapping_bodies:
		if (!body in last_overlapping_bodies):
			if(body.name == "ServerPlayer" or body.name == "ClientPlayer"):
				var pos = body.get_global_position()
				var fix = SGFixed.to_int(fixed_position.y)
				var ratio = fix/pos.y
				if (ratio == 1):
					ratio = 0
				var fixed_ratio = SGFixed.from_float(ratio)
				var y = fixed_ratio	
				if (ratio > 1):
					y = -y
				movement_x = -movement_x
				movement_y = -y
				
			elif(body.name == "UpperObstacle" or body.name == "LowerObstacle"):
				var mid = get_viewport_rect().size / 2
				var fix = SGFixed.to_int(fixed_position.y)
				var y = movement_y
				movement_x = movement_x
				movement_y = -y
	last_overlapping_bodies = overlapping_bodies

