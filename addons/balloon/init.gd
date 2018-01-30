tool
extends EditorPlugin

func _enter_tree():
    add_custom_type("Ballon Text", "Control", preload("assets/balloon.gd"), preload("ico.png"))
    pass

func _exit_tree():
	remove_custom_type("Ballon Text")
	pass
