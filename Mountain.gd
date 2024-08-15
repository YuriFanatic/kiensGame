extends Node3D

@onready var hitRect = $UI/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_player_hit():
	hitRect.visible = true
	await get_tree().create_timer(0.2).timeout
	hitRect.visible = false
	
