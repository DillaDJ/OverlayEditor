class_name EventInterface
extends PanelContainer


@export var caret_on : Texture2D
@export var caret_off : Texture2D

@onready var time_trigger_scn = preload("res://Overlays/Events/Triggers/scn_TimeTrigger.tscn")
@onready var twitch_chat_trigger_scn = preload("res://Overlays/Events/Triggers/scn_TwitchChatTrigger.tscn")

@onready var print_action_scn = preload("res://Overlays/Events/Actions/scn_PrintAction.tscn")
@onready var property_action_scn = preload("res://Overlays/Events/Actions/scn_PropertyAction.tscn")

@onready var trigger_container = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer
@onready var action_container : Control = $HorizontalLayout/VerticalLayout/ActionContainer

@onready var preview : Control = $HorizontalLayout/VerticalLayout/ActionContainer/Preview
@onready var action_fold_button = $HorizontalLayout/VerticalLayout/TriggerBG/TriggerContainer/FoldActions


func _ready():
	action_fold_button.connect("button_down", Callable(self, "toggle_action_visibility"))


func add_trigger_interface(trigger : Trigger):
	var interface : Control
	
	match trigger.type:
		Trigger.Type.TIMED:
			interface = time_trigger_scn.instantiate()
			
			var spinbox : SpinBox = interface.get_node("SpinBox")
			spinbox.value = trigger.trigger_time
			spinbox.connect("value_changed", Callable(trigger, "edit_time"))
		
		Trigger.Type.TWITCH_CHAT:
			interface = twitch_chat_trigger_scn.instantiate()
	
	trigger_container.add_child(interface)
	trigger_container.move_child(interface, 0)


func add_action_interface(action) -> Control:
	var interface
	
	match action.type:
		Action.Type.PRINT:
			interface = print_action_scn.instantiate()
		Action.Type.PROPERTY:
			interface = property_action_scn.instantiate()
	
	action_container.add_child(interface)
	
	if !action_container.is_visible_in_tree():
		toggle_action_visibility()
	preview.hide()
	
	return interface


func remove_action_interface_at(action_idx) -> void:
	if action_container.get_child_count() == 2:
		preview.show()
	
	action_container.get_child(action_idx).queue_free()


func toggle_action_visibility():
	if action_container.is_visible_in_tree():
		action_container.hide()
		action_fold_button.icon = caret_off
	else:
		action_container.show()
		action_fold_button.icon = caret_on
