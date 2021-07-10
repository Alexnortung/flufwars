extends Control

signal purchase_item(itemId)

var shopItemScene = preload("res://client/game/ShopUI/ShopItem.tscn")
var shopCategoryScene = preload("res://client/game/ShopUI/ShopCategory.tscn")

var categoryNodes = {}

func _ready():
	# generate shop items.
	generate_shop_items()
	$TabContainer.connect("gui_input", self, "on_gui_input")
	connect("gui_input", self, "on_gui_input")

func generate_shop_items():
	var shopDataObj = GameData.gameShopData
	var shopData = shopDataObj.shops[shopDataObj.primaryShopName]
	# var appendNode = $TabContainer/Weapons

	for category in shopData["categories"]:
		var shopCategoryNode = shopCategoryScene.instance()
		shopCategoryNode.name = category
		$TabContainer.add_child(shopCategoryNode)
		categoryNodes[category] = shopCategoryNode

	for itemId in shopData.items:
		var shopItemData = shopData.items[itemId]
		var shopItemNode = shopItemScene.instance()
		shopItemNode.set_shop_item_data(shopItemData)
		var appendNode = categoryNodes[shopItemData["category"]]
		appendNode.add_child(shopItemNode)
		shopItemNode.connect("pressed", self, "pressed_purchase_item", [itemId])

func pressed_purchase_item(itemId):
	print("Player pressed item to purcahse %s" % itemId)
	emit_signal("purchase_item", itemId)

func get_game_node():
	return get_node("../..").get_game_node()

func on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		accept_event()
		
