extends Node2D

# Constante de quantos pixels o player vai se mover a cada input
export var CONSTANT_SPEED = 12

# Obtem o input do usuário
func _get_local_input() -> Dictionary:
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var input := {}
	if input_vector != Vector2.ZERO:
		if(input_vector[0] != 0): 
			#Restringir o movimento apenas para cima e para baixo
			input_vector[0] = 0
		input["input_vector"] = input_vector
	
	return input

# Roda a cada tick
# De forma que caso mais de um tick seja necessário em um mesmo frame
# Essa função é chamada várias vezes (isso é necessário para o rollback)
func _network_process(input: Dictionary) -> void:
	#Obtem um input ou prevê o input (predição básica)
	position += input.get("input_vector", Vector2.ZERO) * CONSTANT_SPEED
	

"""
	Funções para salvar e carregar estados de jogo
"""
func _save_state() -> Dictionary:
	return {
		position = position,
	}

func _load_state(state: Dictionary) -> void:
	position = state['position']
