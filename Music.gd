extends AudioStreamPlayer

var last = 0
var next = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func random_play():
	next = randi_range(1, 2)
	if(next == last): next = 3
	last = next
	stream = load("res://sounds/" + str(next) + ".mp3")
	play()


func _on_finished():
	random_play()

func process_music_mode(mode):
	match mode:
		0:
			stop()
		1:
			stop()
		2:
			random_play()
		
