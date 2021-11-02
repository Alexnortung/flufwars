var itemsById = {}
var shops = {}
var primaryShopName = "primary"
var current_id : int = 0

enum ItemTypes {
    WEAPON,
}

func _init():
    new_shop(primaryShopName, ["weapons"])
    # add new items here
    #add_item(primaryShopName, "weapons", "Pistol", "res://common/game/weapons/Pistol.tscn", create_item_cost(10), ItemTypes.WEAPON)
    add_item(primaryShopName, "weapons", "Pistol", "pistol", create_item_cost(10), ItemTypes.WEAPON)
    add_item(primaryShopName, "weapons", "Le Baguette", "baguette", create_item_cost(15), ItemTypes.WEAPON)
    add_item(primaryShopName, "weapons", "AK", "ak", create_item_cost(20), ItemTypes.WEAPON)

func get_id():
    current_id += 1
    return current_id

func new_shop(shopName : String, categories : Array):
    shops[shopName] = {
        items = {},
        categories = categories
    }

func add_item(shopName : String, category : String, itemName, res : String, cost : Array, itemType : int, id = get_id()):
    var shopItem = {
        shopName = shopName,
        category = category,
        name = itemName,
        res = res,
        cost = cost,
        itemType = itemType,
        id = id,
    }
    shops[shopName]["items"][id] = shopItem
    itemsById[id] = shopItem

func create_item_cost(cost1 = 0, cost2 = 0, cost3 = 0, cost4 = 0) -> Array:
    return [cost1, cost2, cost3, cost4]