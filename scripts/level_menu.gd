extends Node

# Subscenes
const RandPopup = preload("res://scenes/rand_popup.tscn")

# GUI objects
onready var lvl_list = $"lvl_list"

func _ready():
	
	# Create an item in the list for each level
	for index in range(globals.number_of_levels):
		lvl_list.add_item(str(index + 1))

func open_level(num):
	
	globals.update_last_level(num + 1)
	get_tree().change_scene("res://scenes/game.tscn")

func open_tutorials():
	
	get_tree().change_scene("res://scenes/tutorial.tscn")

func random_level():
	
	$click.play()
	# Create a popup to let user enter seed if wanted
	var popup = RandPopup.instance()
	add_child(popup)
	popup.popup_centered_ratio(0.25)
