extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_back_pressed():
	var options = preload("res://options.tscn").instantiate()
	get_node("/root/main").add_child(options)
	queue_free()


func _on_licences_pressed():
	var licences = preload("res://licences.tscn").instantiate()
	get_node("/root/main").add_child(licences)
	queue_free()
