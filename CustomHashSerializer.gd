extends "res://addons/godot-rollback-netcode/HashSerializer.gd"

func serialize_object(value: Object):
	if value is SGFixedVector2:
		return {_ = 'SGFixedVector2', x = value.x, y = value.y}
	elif value is SGFixedTransform2D:
		return {
			_ = 'SGFixedTransform2D',
			x = {x = value.x.x, y = value.x.y},
			y = {x = value.y.x, y = value.y.y},
			origin = {x = value.origin.x, y = value.origin.y},
		}
	return .serialize_object(value)

func unserialize_object(value: Dictionary):
	match value['_']:
		'SGFixedVector2':
			return SGFixed.vector2(value['x'], value['y'])
		'SGFixedTransform2D':
			var transform = SGFixedTransform2D.new()
			transform.x.x = value['x']['x']
			transform.x.y = value['x']['y']
			transform.y.x = value['y']['x']
			transform.y.y = value['y']['y']
			transform.origin.x = value['origin']['x']
			transform.origin.y = value['origin']['y']
			return transform
	
	return .unserialize_object(value)

