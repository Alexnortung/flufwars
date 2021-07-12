extends HBoxContainer

var resourceIcons = [
	preload("res://assets/resources/emerald.png"),
	preload("res://assets/resources/diamond.png"),
	preload("res://assets/resources/A4.png"),
	preload("res://assets/resources/A4.png"),
]

func init(position : Vector2, amount : int, type : int):
	assert(type >= 0)
	assert(type < len(resourceIcons))
	self.rect_position = position
	var labelText = str(amount)
	if amount >= 0:
		labelText = "+" + labelText
		$AmountLabel.add_color_override("font_color", Color(0.1,0.9,0.1))
	$AmountLabel.text = labelText
	$TextureRect.texture = resourceIcons[type]

func destroy():
	queue_free()
