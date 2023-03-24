extends Button


enum OverlayTypes { PANEL, TEXTURE_PANEL, TEXT, HBOX_CONTAINER, VBOX_CONTAINER, GRID_CONTAINER }


var panel_scn 			: PackedScene = preload("res://Overlays/scn_PanelOverlay.tscn")
var texture_panel_scn 	: PackedScene = preload("res://Overlays/scn_TexturePanelOverlay.tscn")
var text_scn 			: PackedScene = preload("res://Overlays/scn_TextOverlay.tscn")
var hbox_scn 			: PackedScene = preload("res://Overlays/scn_HBoxContainerOverlay.tscn")
var vbox_scn 			: PackedScene = preload("res://Overlays/scn_VBoxContainerOverlay.tscn")
var grid_scn 			: PackedScene = preload("res://Overlays/scn_GridContainerOverlay.tscn")


@export var type_to_create : OverlayTypes


func _ready():
	connect("button_down", Callable(self, "create_overlay").bind(type_to_create))


func create_overlay(type : OverlayTypes):
	var new_overlay : Control
	
	match type:
		OverlayTypes.PANEL:
			new_overlay = panel_scn.instantiate()
		
		OverlayTypes.TEXTURE_PANEL:
			new_overlay = texture_panel_scn.instantiate()
			
		OverlayTypes.TEXT:
			new_overlay = text_scn.instantiate()
			
		OverlayTypes.HBOX_CONTAINER:
			new_overlay = hbox_scn.instantiate()
			
		OverlayTypes.VBOX_CONTAINER:
			new_overlay = vbox_scn.instantiate()
			
		OverlayTypes.GRID_CONTAINER:
			new_overlay = grid_scn.instantiate()
	
	%OverlayElements.add_child(new_overlay)
	sngl_Utility.get_scene_root().emit_signal("overlay_created", new_overlay)
