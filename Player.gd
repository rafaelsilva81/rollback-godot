extends SGKinematicBody2D


# Constante de quantos pixels o player vai se mover a cada input
var speed := 65536*5

# Obtem o input do usuário
func _get_local_input() -> Dictionary:
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	#var normalized_vector = input_vector.normalized()
	
	var input := {}
	if input_vector != Vector2.ZERO:
		if(input_vector[0] != 0): 
			#Restringir o movimento apenas para cima e para baixo
			input_vector[0] = 0
		input["input_vector"] = SGFixed.from_float_vector2(input_vector)
	
	#print("input", input)
	return input

# Roda a cada tick
# De forma que caso mais de um tick seja necessário em um mesmo frame
# Essa função é chamada várias vezes (isso é necessário para o rollback)
func _network_process(input: Dictionary) -> void:
	#Obtem um input ou prevê o input (predição básica)
	var movement_vector := SGFixedVector2.new()
	movement_vector = input.get("input_vector", SGFixed.vector2(0, 0))
	var velocity = fixed_transform.y.copy()
	velocity.imul(movement_vector.y)
	velocity.imul(speed)
	move_and_slide(velocity)

"""
	Funções para salvar e carregar estados de jogo
"""
func _save_state() -> Dictionary:
	var state:= {
		speed = speed
	}
	if fixed_position_y != 0:
		state['fixed_position_y'] = fixed_position_y
	return state

func _load_state(state: Dictionary) -> void:
	fixed_position_y = state['fixed_position_y']
	speed = state['speed']
	sync_to_physics_engine()
