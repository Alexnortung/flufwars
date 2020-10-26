extends CanvasLayer

func set_ammo(amount):
	$AmmoPanel/Label.text = str(amount)


func _get_resource_container():
	return $ResourcesPanel/HBoxContainer

func set_resource1(amount):
	_get_resource_container().get_node("Label").text = str(amount)
func set_resource2(amount):
	_get_resource_container().get_node("Label2").text = str(amount)
func set_resource3(amount):
	_get_resource_container().get_node("Label3").text = str(amount)

func set_resources(arr: Array):
	set_resource1(arr[0])
	set_resource2(arr[1])
	set_resource3(arr[2])
