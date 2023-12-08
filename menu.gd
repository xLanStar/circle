class_name Menu
extends CanvasLayer

signal submit(name: String, color: Color)

@export var name_field: LineEdit
@export var color_picker: ColorPickerButton
var _color: Color

func _ready():
	color_picker.color = _color

func _on_button_pressed():
	if not name_field.text or name_field.text.length() >= 255:
		return
	submit.emit(name_field.text, _color)

func _on_color_changed(color: Color):
	_color = color
