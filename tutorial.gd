extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_close_pressed():
	var file = FileAccess.open("user://data.res", FileAccess.WRITE)
	file.store_var(true)
	# set main scene into play mode
	get_node("/root/main").mode = 1
	# load the hud scene
	var hud = preload("res://hud.tscn").instantiate()
	get_node("/root/main").add_child(hud)
	# kill the tutorial
	queue_free()
