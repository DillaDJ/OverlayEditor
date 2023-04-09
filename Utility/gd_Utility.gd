class_name Utility
extends Node


enum OverlayTypes { PANEL, TEXT }

@onready var caret_on 	: Texture2D = preload("res://Icons/caret-on.png")
@onready var caret_off 	: Texture2D = preload("res://Icons/caret-off.png")

@onready var regex := RegEx.new()

var sync_timer : Timer


func _ready():
	var window : Window = get_tree().get_root()
	window.set_flag(Window.FLAG_TRANSPARENT, true)
	
	sync_timer = Timer.new()
	sync_timer.wait_time = 1.0
	sync_timer.one_shot = true
	add_child(sync_timer)


func change_scene(scene):
	var new_scene : String
	
	match scene:
		"edit":
			new_scene = "res://scn_EditMode.tscn"
		
		"overlay":
			new_scene = "res://scn_OverlayMode.tscn"
		
		_:
			return
	
	get_tree().change_scene_to_file(new_scene)


func get_scene_root():
	return get_tree().get_current_scene()


func gcd(a, b):
	var temp
	
	while b != 0:
		temp = a
		a = b
		b = temp % b
	
	return a


# Formatted like: [parent, [child, [child of child], child], nochildren, parent, [child], ...]
func get_nested_children(node : Node) -> Array:
	var children : Array = []
	
	for child in node.get_children():
		children.append(child)
		
		var deep_children = get_nested_children(child)
		if deep_children.size() > 0:
			children.append(deep_children)
	
	return children


# Formatted in the same way as the above function but made into a 1D array
func get_nested_children_flat(node : Node) -> Array[Node]:
	var children : Array[Node] = []
	
	for child in node.get_children():
		children.append(child)
		
		var deep_children = get_nested_children_flat(child)
		for deep_child in deep_children:
			children.append(deep_child)
	
	return children


func get_unique_name_amongst_siblings(new_name : String, node : Node, parent : Node) -> String:
	var node_name := new_name.strip_edges()
	var name_clash_ints : Array[int] = []
	var name_clash := false
	
	# Check if node's name is result of previous clash
	regex.compile("(.*) \\((\\d*)\\)$")
	
	var node_match = regex.search(new_name)
	if node_match:
		node_name = node_match.strings[1]
	
	# Check siblings for lowest clash
	regex.compile("%s \\((\\d*)\\)$" % node_name)
	
	for sibling in parent.get_children():
		if sibling == node:
			continue
		
		var sibling_match  = regex.search(sibling.name)
		if sibling_match:
			name_clash_ints.append(sibling_match.strings[1].to_int())
		elif sibling.name == node_name:
			name_clash = true
	
	if name_clash:
		name_clash_ints.sort()
		
		for i in range(name_clash_ints.size() + 1):
			if i + 1 > name_clash_ints.size() or i + 1 != name_clash_ints[i]:
				node_name = "%s (%d)" % [node_name, i + 1]
				break
	
	return node_name


func get_screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size
