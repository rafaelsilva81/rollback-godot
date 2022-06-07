extends SGArea2D

onready var collision_shape = $SGCollisionShape2D

const MOVEMENT_SPEED := 65536*4
var speed = MOVEMENT_SPEED

var vector: SGFixedVector2
var last_overlapping_bodies: Array

func _ready() -> void:
	vector = SGFixed.vector2(MOVEMENT_SPEED, 0)
	
func _network_process(input: Dictionary) -> void:
	fixed_position.iadd(vector)
	var overlapping_bodies = get_overlapping_bodies(true)
	
			
	for body in overlapping_bodies:
		if (!body in last_overlapping_bodies):
			if(body.name == "ServerPlayer" or body.name == "ClientPlayer"):
				vector.x = -vector.x
	
	last_overlapping_bodies = overlapping_bodies
	
func _save_state() -> Dictionary:
	var state:= {
		speed = speed,
		#fixed_position_x = fixed_position_x,
		vector = vector
	}
	#if fixed_position_y != 0:
		#state['fixed_position_y'] = fixed_position_y
	return state

func _load_state(state: Dictionary) -> void:
	#fixed_position_x = state['fixed_position_x']
	#fixed_position_y = state['fixed_position_y']
	speed = state['speed']
	vector = state['vector']
	sync_to_physics_engine()
