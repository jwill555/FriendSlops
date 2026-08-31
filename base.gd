extends Node3D

@export var gameBase : PackedScene



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(12345) #for creating server the peers id is automatically 1
	multiplayer.multiplayer_peer = peer
	NetworkManger.host = peer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(onConnected)
	multiplayer.peer_disconnected.connect(onDisconnect)
	

func onConnected(peerID):
	print("Peer connected: ",  peerID)

func onDisconnect(peerID):
	print("Peer disconncted: ", peerID)


func _on_button_2_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("10.0.0.171",12345) #Peer id is this integer thats all thats needed for webrtc
	multiplayer.multiplayer_peer = peer
	
	

@rpc("any_peer","call_local")
func BlueShit():
	$AnimationPlayer.play("BlueShit")


func _on_button_3_pressed() -> void:
	BlueShit.rpc()

@rpc("any_peer","call_local")
func JoinGame():
	get_tree().change_scene_to_packed(gameBase)

func _on_button_4_pressed() -> void:
	JoinGame.rpc()
