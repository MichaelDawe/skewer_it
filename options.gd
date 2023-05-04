extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_credits_pressed():
	var credits = preload("res://credits.tscn").instantiate()
	get_node("/root/main").add_child(credits)
	queue_free()


func _on_back_pressed():
	var menu = preload("res://menu.tscn").instantiate()
	get_node("/root/main").add_child(menu)
	queue_free()
