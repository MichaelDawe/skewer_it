extends Node3D

var mode = 0 # 0 = menu, 1 = gameplay, 2 = paused, ...
var quit = false # used to indicate that the script should delete all 3D elements if the player has quit

# Called when the node enters the scene tree for the first time.
func _ready():
	var menu = preload("res://menu.tscn").instantiate()
	add_child(menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
