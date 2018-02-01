tool
extends EditorPlugin

func _enter_tree():
    add_custom_type("Balloon Text", "Control", preload("balloon.gd"), preload("assets/icon_balloon.png"))
    pass

func _exit_tree():
	remove_custom_type("Balloon Text")
	pass
