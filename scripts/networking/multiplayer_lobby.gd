extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var player_spawner = $PlayerSpawner

@export var player_scene : PackedScene

#const Player = preload("res://scenes/player.tscn")
#const Player = preload("res://scenes/player_rpc.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	main_menu.hide()
	
	enet_peer.create_client('localhost', PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = player_scene.instantiate()
	player.player_id = peer_id
	player_spawner.add_child(player, true)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
