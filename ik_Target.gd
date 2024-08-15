extends Marker3D

@export var step_target: Node3D
@export var step_distance: float = 18.0

@export var adjacent_target: Node3D
@export var opposite_target: Node3D

var is_stepping := false

#steps current leg and oppoosite leg if adjacent leg is not stepping
func _process(delta):
	if !is_stepping && !adjacent_target.is_stepping && (global_position.distance_to(step_target.global_position)) > step_distance:
		step()
		opposite_target.step()

func step():
	var target_pos = step_target.global_position
	is_stepping = true
	var half_way = (global_position + step_target.global_position) / 2
	var leg_height = owner.basis.y + Vector3(0, 10, 0)
	
	#animates leg
	var t = get_tree().create_tween().set_speed_scale (0.8)
	t.tween_property(self, "global_position", half_way + leg_height, 0.1)
	t.tween_property(self, "global_position", target_pos, 0.1)
	t.tween_callback(func(): is_stepping = false)
