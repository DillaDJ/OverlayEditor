extends Button


enum OverlayTypes { PANEL, TEXT }


var panel_scn : PackedScene = preload("res://Overlays/scn_PanelOverlay.tscn")
var text_scn : PackedScene = preload("res://Overlays/scn_TextOverlay.tscn")


@export var type_to_create : OverlayTypes


func _ready():
	connect("button_down", Callable(self, "create_overlay").bind(type_to_create))


func create_overlay(type : OverlayTypes):
	var new_overlay : Control
	
	match type:
		OverlayTypes.PANEL:
			new_overlay = panel_scn.instantiate()
			
		OverlayTypes.TEXT:
			new_overlay = text_scn.instantiate()
	
	%OverlayElements.add_child(new_overlay)
	sngl_Utility.get_scene_root().emit_signal("overlay_created", new_overlay)
