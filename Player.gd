extends KinematicBody

export var speed = 10
export (NodePath) onready var camera_node = NodePath("../Camera")
export (NodePath) onready var navigation_node = NodePath("../Navigation")

var space_state : PhysicsDirectSpaceState
var path = []
var path_index = 0

func _ready():	
	space_state = get_world().direct_space_state
	
func _input (event):
	var mouse_event = event as InputEventMouseButton

	if mouse_event == null:
		return

	if mouse_event.pressed and mouse_event.button_index == BUTTON_LEFT:
		var camera = get_node(camera_node)
		var navigation = get_node(navigation_node)
		var from = camera.project_ray_origin(mouse_event.position)
		# 1000 = length of ray
		var to = from + camera.project_ray_normal(mouse_event.position) * 1000
		var result = space_state.intersect_ray(from, to)
		var collider = result.collider as CollisionObject
		if collider:
			path = navigation.get_simple_path(global_transform.origin, result.position)
			path_index = 0
			
func _physics_process(delta):
	if path_index < path.size():
		var direction = path[path_index] - global_transform.origin
		if direction.length() < 1:
			path_index += 1
		else:
			var pos = direction.normalized()
			look_at(pos * 1000, Vector3(0, 1, 0))
			move_and_slide(pos * speed)
