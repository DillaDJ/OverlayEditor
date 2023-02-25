extends Button


var panel_scn : PackedScene = preload("scn_PanelOverlay.tscn")
var text_scn : PackedScene = preload("scn_TextOverlay.tscn")


@export var type_to_create : OverlayElement.OverlayTypes


func _ready():
	connect("button_down", Callable(self, "create_overlay").bind(type_to_create))


func create_overlay(type : OverlayElement.OverlayTypes):
	var new_overlay
	
	match type:
		OverlayElement.OverlayTypes.PANEL:
			new_overlay = panel_scn.instantiate()
			
		OverlayElement.OverlayTypes.TEXT:
			new_overlay = text_scn.instantiate()
	
	%OverlayElements.add_child(new_overlay)
