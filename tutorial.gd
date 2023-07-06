extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_close_pressed():
	var file = FileAccess.open("user://firstopen.res", FileAccess.WRITE)
	file.store_var(true)
	file.close()
	# load the hud scene
	var hud = preload("res://hud.tscn").instantiate()
	get_node("/root/main").add_child(hud)
	# set main scene into play mode
	get_node("/root/main").mode = 1
	# run the play script on the main scene
	get_node("/root/main").play()
	# kill the tutorial
	queue_free()


func _on_menu_pressed():
	var menu = preload("res://menu.tscn").instantiate()
	get_node("/root/main").add_child(menu)
	queue_free()
