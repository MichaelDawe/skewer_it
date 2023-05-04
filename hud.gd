extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pause_pressed():
	get_node("/root/main").mode = 2
	var pause = preload("res://pause.tscn").instantiate()
	get_node("/root/main").add_child(pause)
	queue_free()
