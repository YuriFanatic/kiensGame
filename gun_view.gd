extends Camera3D

@onready var fps_rig = $fpsRig
@onready var animation_player = $fpsRig/revolver/AnimationPlayer
@onready var aim_ray = $fpsRig/revolver/aimRay

var revolverInUse = true;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta * 5)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0 , delta * 5)
	
func sway(swayAmount):
	fps_rig.position.x -= swayAmount.x * 0.0001
	fps_rig.position.y += swayAmount.y * 0.0003
	
func _input(event):
	if(event.is_action_pressed("shoot")):
		if !animation_player.is_playing():
			animation_player.play("fire")
			if aim_ray.is_colliding():
				if aim_ray.get_collider().is_in_group("enemy"):
					aim_ray.get_collider().hit()
	if(event.is_action_pressed("reload")):
		animation_player.play("")
	if(event.is_action_pressed("use")):
		revolverInUse = !revolverInUse
		if(revolverInUse):
			animation_player.play("putAway")
		else:
			animation_player.play("pullUp")
