extends Node2D

onready var network_timer = $NetworkTimer
const COLOR_WHITE = Color("#ffffff")
#var initial_position;

func _network_spawn(data: Dictionary) -> void:
	global_position = data['position']
	var c = Color(data['_color'])
	self.modulate = c
	network_timer.start()
	#explosion_timer.start()

func _network_despawn() -> void:
	#global_position = initial_position
	self.modulate = COLOR_WHITE
	
func _on_NetworkTimer_timeout():
	SyncManager.despawn(self)
