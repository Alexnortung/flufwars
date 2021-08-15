extends Control

var shopItemData

func _ready():
	pass

func set_shop_item_data(data):
	shopItemData = data
	print(data)
	find_node("ItemName").text = data["name"]
	find_node("PriceTag").text = str(data.cost[0])
