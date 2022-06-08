extends SGArea2D

onready var collision_shape = $SGCollisionShape2D
const MOVEMENT_SPEED := 65536*1

var vector : SGFixedVector2
var pos : SGFixedVector2
var last_overlapping_bodies: Array

func _network_spawn(data: Dictionary) -> void:
	global_position = data['position']
	vector = SGFixed.vector2(MOVEMENT_SPEED, 0)
	fixed_position = SGFixed.from_float_vector2(global_position)
	#print("Before : ", fixed_position_y)
func _physics_process(delta):
	fixed_position.iadd(vector)
	sync_to_physics_engine()
	
	#print("Adding", vector.y)
	#print("After : ", fixed_position_y)
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if (!body in last_overlapping_bodies):
			if(body.name == "ServerPlayer" or body.name == "ClientPlayer"):
				vector.x = -vector.x
				var pos = body.get_floor_angle()
				print(pos)
				
				
	last_overlapping_bodies = overlapping_bodies

