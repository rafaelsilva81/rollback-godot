extends SGFixedNode2D

# Declaração de elementos da engine para acessar depois
onready var connection_panel = $ConnectionCanvas/ConnectionPanel 
onready var host_field = $ConnectionCanvas/ConnectionPanel/GridContainer/HostField
onready var port_field = $ConnectionCanvas/ConnectionPanel/GridContainer/PortField
onready var message_label = $ConnectionCanvas/MessageLabel
onready var sync_lost_label = $ConnectionCanvas/SyncLostLabel
onready var fps_counter = $Background/FpsCounter

onready var P1Label = $Background/P1Label
onready var P2Label = $Background/P2Label

const Ball = preload("res://Ball.tscn")

const LOG_FILE_DIRECTORY = 'res://logs/'

export var logging_enabled := false
export var fps_enabled := true

#Função que é executada por padrão assim que a cena é carregada
func _ready() -> void:
	
	if (fps_enabled):
		fps_counter.show()
		
	""" 
		Esses são 3 sinais padrões da ENet que indicam 
		quando um peer for conectado ou desconectado ou o servidor fechado
		Quando um desses sinais acontece uma função callback desse script é chamada
	"""
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	
	
	"""
		Esses são 4 sinais padrões do SyncManager
		Chamarão funções callback dentro da função
	"""
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")

# Função callbakc quando o botão "Iniciar como Servidor" for clicado
func _on_ServerButton_pressed() -> void:
	
	# Cria um "servidor" dentro da camada de multiplayer do godot (ENet)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(port_field.text), 1)
	get_tree().network_peer = peer
	
	#Deixa o painel de conexão invisível e mostra uma mensagem
	connection_panel.visible = false
	message_label.text = "Listening..." #TODO: Alterar mensagem

# Função callback quando o botão "Iniciar como Cliente" for clicado
func _on_ClientButton_pressed() -> void:
	
	#Cria um "cliente" dentro da camada de multiplayer do godot (Enet)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_field.text, int(port_field.text))
	get_tree().network_peer = peer
	
	#Deixa o painel de conexão invisível e mostra uma mensagem
	connection_panel.visible = false
	message_label.text = "Connecting..." #TODO: Alterar mensagem

# Função callback para quando um peer for conectado do Enet
func _on_network_peer_connected(peer_id: int):
	
	# Adiciona o peer ao SyncManager
	message_label.text = "Connected!"
	SyncManager.add_peer(peer_id)
	
	"""
		O "servidor" não é responsável por nada da gameplay,
		porém a Enet requer que um dos nós seja um servidor
	"""
	
	#Diz de qual peer é cada player
	#Um jogador sempre será o "servidor" que recebe o id 1
	$ServerPlayer.set_network_master(1)
	if get_tree().is_network_server():
		# Já o outro jogador checa se ele mesmo é o "servidor"
		# Caso positivo ele atribui para o cliente o peer_id obtido dele
		$ClientPlayer.set_network_master(peer_id)
	else:
		# Caso contrário, ele é o cliente então ele gera um id unico
		$ClientPlayer.set_network_master(get_tree().get_network_unique_id())
	
	if get_tree().is_network_server(): #Se for um "Servidor"
		message_label.text = "Starting..." #Mensagem
		# Timeout de 2 segundos (para obter dados de ping)
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start() #Inicia o SyncManager

#Função callback quando um peer desconecta do Enet
func _on_network_peer_disconnected(peer_id: int):
	# Remove o peer do SyncManager
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id) 

func _on_server_disconnected() -> void:
	#Chama a função para desconectar um peer passando um id 1
	#Um "servidor" Enet sempre terá o id 1
	_on_network_peer_disconnected(1)

#Callback para quando o botão "RESET" for apertado
func _on_ResetButton_pressed() -> void:
	# Para o SyncManager (e a partida) 
	# Remove remove todos os peers (isso deve ser feito no fim da sessao)
	SyncManager.stop()
	SyncManager.clear_peers()
	
	#Remove os peers e conexões do Enet
	var peer = get_tree().network_peer
	if peer:
		peer.close_connection()
	
	#Recarrega a cena
	get_tree().reload_current_scene()

#Função callback para quando o SyncManager iniciar
func _on_SyncManager_sync_started() -> void:
	message_label.text = "Started!"
	SyncManager.spawn("Ball", self, Ball, { position = get_viewport_rect().size / 2})
	
	if logging_enabled:
		var dir = Directory.new()
		if not dir.dir_exists(LOG_FILE_DIRECTORY):
			dir.make_dir(LOG_FILE_DIRECTORY)
		
		var datetime = OS.get_datetime(true)
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
			datetime['year'],
			datetime['month'],
			datetime['day'],
			datetime['hour'],
			datetime['minute'],
			datetime['second'],
			SyncManager.network_adaptor.get_network_unique_id(),
		]
		
		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)
		
#Função callback para quando o SyncManager parar
func _on_SyncManager_sync_stopped() -> void:
	if logging_enabled:
		SyncManager.stop_logging()

#Função callback para quando o SyncManager perder a sincronização
func _on_SyncManager_sync_lost() -> void:
	sync_lost_label.visible = true

#Função callback para quando o SyncManager recuperar a sincronização
func _on_SyncManager_sync_regained() -> void:
	sync_lost_label.visible = false

#Função callback para quando o SyncManager gerar erros
func _on_SyncManager_sync_error(msg: String) -> void:
	
	#Imprime o erro na tela
	message_label.text = "Fatal sync error: " + msg
	sync_lost_label.visible = false
	
	#Fecha toda a conexão e remove os peers
	var peer = get_tree().network_peer
	if peer:
		peer.close_connection()
	SyncManager.clear_peers()
	
func _process(_delta):
	if (fps_enabled):
		fps_counter.text = str("FPS: ", Engine.get_frames_per_second())

