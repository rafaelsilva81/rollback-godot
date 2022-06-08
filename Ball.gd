extends SGArea2D

onready var collision_shape = $SGCollisionShape2D

var movement_x := 65536*4
var movement_y := 0
#const MOVEMENT_SPEED := 65536*4
#var speed = MOVEMENT_SPEED

var vector: SGFixedVector2
var last_overlapping_bodies: Array

#func _ready() -> void:
	#vector = SGFixed.vector2(movement_x, movement_y)
	
func _network_process(input: Dictionary) -> void:
	fixed_position.iadd(SGFixed.vector2(movement_x, movement_y))
	sync_to_physics_engine()
	
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if (!body in last_overlapping_bodies):
			if(body.name == "ServerPlayer" or body.name == "ClientPlayer"):
				
				
	last_overlapping_bodies = overlapping_bodies
	
func _save_state() -> Dictionary:
	var state:= {
		fixed_position_x = fixed_position_x,
		fixed_position_y = fixed_position_y,
		#fixed_transform = fixed_transform
	}
	return state

func _load_state(state: Dictionary) -> void:
	fixed_position_x = state['fixed_position_x']
	fixed_position_y = state['fixed_position_y']
	#fixed_transform = state['fixed_transform']
	sync_to_physics_engine()
