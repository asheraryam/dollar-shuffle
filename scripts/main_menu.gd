extends Node

# Preload all menus accessable from this one
const lvl_menu = preload("res://scenes/lvl_menu.tscn")
const opts_menu = preload("res://scenes/opts_menu.tscn")
const recs_menu = preload("res://scenes/records_menu.tscn")

# Button objects
onready var cont_btn = get_node("cont_button")
onready var level_btn = get_node("level_button")
onready var recs_btn = get_node("records_button")
onready var opt_btn = get_node("opt_button")
onready var quit_btn = get_node("quit_button")

func _ready():
	# Connect buttons to respective functions
	cont_btn.connect("pressed", self, "return_level")
	level_btn.connect("pressed", self, "choose_level")
	recs_btn.connect("pressed", self, "open_records")
	opt_btn.connect("pressed", self, "open_options")
	quit_btn.connect("pressed", self, "quit_game")

# Return to last unsolved puzzle
func return_level():
	# Load instance of game scene
	var level_scene = ResourceLoader.load("res://scenes/game.tscn")
	get_tree().get_root().add_child(level_scene.instance())

# Choose level number from list
func choose_level():
	get_parent().get_parent().stack_menu(lvl_menu)

# Open the records list
func open_records():
	get_parent().get_parent().stack_menu(recs_menu)

# Open the options menu
func open_options():
	get_parent().get_parent().stack_menu(opts_menu)

# Open the tutorial levels
func open_tutorials():
	self.queue_free()
	get_tree().change_scene("res://scenes/tutorial.tscn")

# Close the game
func quit_game():
	get_tree().quit()
