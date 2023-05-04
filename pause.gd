extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_menu_pressed():
	get_node("/root/main").mode = 0
	get_node("/root/main").quit = true
	var menu = preload("res://menu.tscn").instantiate()
	get_node("/root/main").add_child(menu)
	queue_free()


func _on_resume_pressed():
	var hud = preload("res://hud.tscn").instantiate()
	get_node("/root/main").add_child(hud)
	get_node("/root/main").mode = 1
	queue_free()
