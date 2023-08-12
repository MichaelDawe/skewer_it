extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	# get screen size and scale self to fit width.
	var ratio = float(get_viewport().size.x) / float(get_viewport().size.y)
	scale *= Vector3(ratio, ratio, 1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
