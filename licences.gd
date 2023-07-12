extends Control

var index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_back_pressed():
	var credits = preload("res://credits.tscn").instantiate()
	get_node("/root/main").add_child(credits)
	queue_free()


func _on_next_pressed():
	match index:
		0:
			index += 1
			$VBoxContainer/MarginContainer/licencetext.set_text(
				'This game uses Godot Engine, available under the following license:

Copyright (c) 2014-present Godot Engine contributors. Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
)
		1:
			index += 1
			$VBoxContainer/MarginContainer/licencetext.set_text(
				'Godot includes ENet, available under the following license:

Copyright (c) 2002-2020 Lee Salzman

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
)
		2:
			index += 1
			$VBoxContainer/MarginContainer/licencetext.set_text(
				'Godot includes mbed TLS, available under the following license:

Copyright The Mbed TLS Contributors

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.'
)
		3:
			index += 1
			$VBoxContainer/MarginContainer/licencetext.set_text(
				'Godot uses FreeType to render fonts, available under the following license:

Portions of this software are copyright © 2023 The FreeType Project (www.freetype.org). All rights reserved.'
)
		4:
			index += 1
			$VBoxContainer/MarginContainer/licencetext.set_text(
				'Some shader source files are licenced under 
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
By Michael Dawe, partially based on:
The Universe Within - by Martijn Steinrucken aka BigWings 2018
Email:countfrolic@gmail.com Twitter:@The_ArtOfCode
License under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
'
)
		5:
			var credits = preload("res://credits.tscn").instantiate()
			get_node("/root/main").add_child(credits)
			queue_free()
