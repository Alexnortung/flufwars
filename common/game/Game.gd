extends Node2D

signal spawn_flag
signal spawn_projectile

var gameStarted : bool = false
var gameStartCountdownTime = 3
var levelNode : Node2D
var players = {}
var projectiles = {}
# Entities are other Nodes with ids
var entities = {}
const projectileTypes = {
	base_projectile = preload("res://common/game/projectiles/BaseProjectile.tscn"), # 0
}

const weaponTypes = {
	# BaseWeapon is abstract so we should not use it here
	pistol = preload("res://common/game/weapons/Pistol.tscn"),
}

func _ready():
	$Countdown.connect("countdown_finished", self, "on_start_game_countdown_finish")
	print("Entering game")
	get_tree().paused = true
	
	ClientNetwork.connect("remove_player", self, "remove_player")
	
	pre_configure()


func remove_player(playerId: int):
	var playerNode = get_node(str(playerId))
	playerNode.queue_free()


func pre_configure():
	var order := 0
	var sortedPlayers = []

	loadLevel()

	for playerId in GameData.players:
		sortedPlayers.push_back(playerId)
	
	sortedPlayers.sort()
	# var i = 0

	var teamNodes = $Level.get_node("Teams").get_children()
	var teamIndex = 0
	for teamData in GameData.teams:
		# print("Team data")
		# print(teamData)
		# var teamData = GameData.teams[teamIndex]
		var teamNode = teamNodes[teamIndex]
		var playerSpawnNodes = teamNode.get_node("PlayerSpawns").get_children()
		var i = 0
		for playerId in teamData.players:
			var playerData = teamData.players[playerId]
			print("player data")
			print(playerData)
			var spawnNode = playerSpawnNodes[i]
			# create player node
			var playerNode = spawn_player(playerData.id, teamNode, spawnNode)
			i += 1
			print("created player: id: " + str(playerNode.id) + " teamIndex: " + str(playerNode.teamIndex))
		teamIndex += 1
	
	if not get_tree().is_network_server():
		# Report that this client is done
		rpc_id(ServerNetwork.SERVER_ID, "on_client_ready", get_tree().get_network_unique_id())

func loadLevel():
	print("SCENE PATH")
	print(GameData.mapInfo.levelScenePath)
	var levelScene = load(GameData.mapInfo.levelScenePath)
	levelNode = levelScene.instance()
	levelNode.set_name("Level")
	add_child(levelNode)

# virtual lobby
func load_lobby():
	pass
	

func spawn_player(playerId, teamNode, spawnNode):
	var teamIndex = teamNode.teamIndex
	print("Creating player game object")
	
	var player = GameData.players[playerId]
	var playerName = player[GameData.PLAYER_NAME]
	
	var scene = get_player_scene() 
	
	var playerNode = scene.instance()
	playerNode.init(playerId, teamIndex, spawnNode)
	playerNode.set_network_master(playerId)
	playerNode.set_name(str(playerId))
	
	playerNode.position = spawnNode.position

	add_camera_to_player(playerId, playerNode)
	
	playerNode.get_node("NameLabel").text = playerName
	playerNode.get_node("PlayerAnim").set_sprite_frames(GameData.mapInfo.colorDic[teamIndex].playerAnim)
	teamNode.get_node("Players").add_child(playerNode)
	spawnNode.playerNode = playerNode
	players[playerId] = playerNode
	playerNode.connect("player_dead", self, "player_dies")
	playerNode.get_node("RespawnTimer").connect("timeout", self, "respawn_player", [playerId])
	return playerNode

func add_camera_to_player(playerId: int, playerNode: Node2D):
	pass

#virtual function
func get_player_scene():
	pass

func get_player(playerId : int) -> Node2D:
	for _playerId in players:
		var player = players[_playerId]
		if playerId == player.id:
			return player
	return null

func get_flag(teamIndex):
	return $Level.get_flag(teamIndex)

func is_flag_taken(teamIndex):
	var flag = get_flag(teamIndex)
	if flag == null:
		return true
	return false

func on_pre_configure_complete():
	print("All clients are configured. Starting the game.")
	start_game_countdown()

remotesync func on_flag_picked_up(teamIndex : int, playerId : int):
	var flag = get_flag(teamIndex)
	var player = get_player(playerId)
	flag.picked_up(flag, player)
	print("Game remote: picking up the flag. Teamindex: " + str(teamIndex) + " playerId: " + str(playerId))

remotesync func on_take_damage(playerId: int, newHealth: int):
	get_player(playerId).update_health(newHealth)

func on_spawn_projectile(position: Vector2, direction: Vector2, projectileType: String, projectileId: String):
	# print("spawning projectile")
	var projectileLoad = projectileTypes[projectileType]
	var projectile = projectileLoad.instance()
	projectile.init(position, direction, projectileId)
	add_child(projectile)
	projectiles[projectileId] = projectile
	emit_signal("spawn_projectile", projectile)
	return projectile

remotesync func on_respawn_player(playerId: int):
	var player = get_player(playerId)
	player.position = player.playerSpawn.position
	player.health = player.initHealth
	player.kill_player(false)

remotesync func on_player_dead(playerId):
	get_player(playerId).kill_player(true)

func player_dies(playerId: int):
	rpc("on_player_dead", playerId)

func respawn_player(playerId: int):
	pass

func on_projectile_hit(projectileId : String):
	on_projectile_despawn(projectileId)

func on_projectile_despawn(projectileId : String):
	projectiles[projectileId].queue_free()
	projectiles.erase(projectileId)

remotesync func on_flag_captured(playerId):
	get_player(playerId).flag_captured()

remotesync func resources_picked_up(resourceSpawnerId: String):
	$Level.get_resource_spawner(resourceSpawnerId).on_pickup()

remotesync func resource_spawned(resourceSpawnerId: String):
	$Level.get_resource_spawner(resourceSpawnerId).on_spawn_resource()

remote func end_game():
	print("sender is: " + str(get_tree().get_rpc_sender_id()))
	if get_tree().get_rpc_sender_id() == 1 or get_tree().is_network_server():
		print("sent from server")
		GameData.teams = []
		load_lobby()

func spawn_weapon(weaponType : String, id : String, position : Vector2):
	var weapon = weaponTypes[weaponType].instance()
	weapon.init(id, position)
	entities[id] = weapon
	add_child(weapon)
	return weapon

func start_game_countdown():
	print("countdown started")
	$Countdown.start(gameStartCountdownTime)

func on_start_game_countdown_finish():
	print("countdown finisehd")
	get_tree().paused = false
