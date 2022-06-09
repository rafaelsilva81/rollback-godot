extends Node2D

# Constante de quantos pixels o player vai se mover a cada input
export var CONSTANT_SPEED = 12

const Paintblob = preload("res://elements/Paintblob.tscn")
const PaintDetail = preload("res://elements/PaintDetail.tscn")

onready var color_picker = get_tree().get_root().get_node("Main/ColorselectCanvas/ColorselectPanel/ColorPicker")	#paint_brush.modulate = _color
var _color

func _ready() -> void:
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")

func _on_SyncManager_sync_started() -> void:
	_color = color_picker.get_pick_color()
	
func _get_local_input() -> Dictionary:
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input := {}
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	if Input.is_action_pressed("ui_accept"):
		input["painting"] = true
	input["color"] = _color.to_html(false)
	
	return input

# Roda a cada tick
# De forma que caso mais de um tick seja necessário em um mesmo frame
# Essa função é chamada várias vezes (isso é necessário para o rollback)
func _network_process(input: Dictionary) -> void:
	if (SyncManager.current_tick == 2):
		print(self.get_node(self.get_path()))
		SyncManager.spawn("PaintDetail", self.get_node(self.get_path()), PaintDetail, {_color =  input.get("color", _color) })
	#Obtem um input ou prevê o input (predição básica)
	position += input.get("input_vector", Vector2.ZERO) * CONSTANT_SPEED
	if input.get("painting", false):
		SyncManager.spawn("Paintblob", get_parent(), Paintblob, { position = global_position, _color = input['color'] })


"""
	Funções para salvar e carregar estados de jogo
"""
func _save_state() -> Dictionary:
	return {
		position = position,
	}

func _load_state(state: Dictionary) -> void:
	position = state['position']
