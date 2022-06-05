extends Node2D

# Obtem o input do usuário
func _get_local_input() -> Dictionary:
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var input := {}
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	
	return input

# Roda a cada tick
# De forma que caso mais de um tick seja necessário em um mesmo frame
# Essa função é chamada várias vezes (isso é necessário para o rollback)
func _network_process(input: Dictionary) -> void:
	#Obtem um input ou prevê o input (predição básica)
	position += input.get("input_vector", Vector2.ZERO) * 8

"""
	Funções para salvar e carregar estados de jogo
"""
func _save_state() -> Dictionary:
	return {
		position = position,
	}

func _load_state(state: Dictionary) -> void:
	position = state['position']
