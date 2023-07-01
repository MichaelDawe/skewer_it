extends Node3D

var mode = 0 # 0 = menu, 1 = gameplay, 2 = paused, ...
var quit = false # used to indicate that the script should delete all 3D elements if the player has quit
var speed = 1 # 0 = easy / slow, 1 = normal, 2 = hard / fast
var speedBoost = 1.0 # speeeeeeeeds the game up over time
var spawnNowQ = 5.5 # time, in seconds, since last spawn.
var spawnInterval = 2.0 # time, in seconds, for each item to spawn, at the startttt.

# Called when the node enters the scene tree for the first time.
func _ready():
	# read difficutly from file
	if FileAccess.file_exists("user://speed.res"):
		var file = FileAccess.open("user://speed.res", FileAccess.READ)
		speed = file.get_8()
		file.close()
	# open menu scene
	var menu = preload("res://menu.tscn").instantiate()
	add_child(menu)
	
	# set up items for first spawn
	for n in $Vegies.get_children():
		# scale to 0
		n.scale = Vector3(0, 0, 0)
		# spawn in random location
		n.position.z = 0
		n.position.x = (randf() * 60) - 30
		n.position.y = (randf() * 60) - 30
		# assign random rotation 
		n.set_meta("rotation", Vector3(randf(), randf(), randf()))
		n.set_meta("spawned", false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# process pause signal
	if mode == 1:
		# spawning counter
		spawnNowQ += delta
		# process items
		for n in $Vegies.get_children():
			# set location in shader for pickup effects
			n.get_active_material(0).set_shader_parameter("pozition", n.position.z)
			# process postion and rotation
			var rotationMeta = n.get_meta("rotation")
			if n.get_meta("spawned"):
				# update scale
				n.scale += Vector3(0.3, 0.3, 0.3) * delta
				# update position
				n.position.z += 20 * delta * speedBoost
				# apply rotation from saved random rotation direction
				n.rotate(Vector3(1, 0, 0), rotationMeta[0] * delta)
				n.rotate(Vector3(0, 1, 0), rotationMeta[1] * delta)
				n.rotate(Vector3(0, 0, 1), rotationMeta[2] * delta)
				
				# send objects home ('kill' them)
				if n.position.z > 128:
					# scale to 0
					n.scale = Vector3(0, 0, 0)
					# re-spawn in random location
					n.position.z = 0
					n.position.x = (randf() * 60) - 30
					n.position.y = (randf() * 60) - 30
					# assign random rotation 
					n.set_meta("rotation", Vector3(randf(), randf(), randf()))
					# un-spawn, make inactive
					n.set_meta("spawned", false)
					
					
		# spawn new item
		if spawnNowQ > spawnInterval / speedBoost:
			$Vegies.get_child(randi_range(0, 14)).set_meta("spawned", true)
			spawnNowQ = 0.0
		
		# render skewer
		
			
		# process score
