extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	# get screen size and scale self to fit width.
	var aspect = float(get_viewport().size.x) / float(get_viewport().size.y)
	scale *= Vector3(aspect, aspect, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
