extends Node3D

@export var player : PackedScene
@onready var spawner = $MultiplayerSpawner



var readyForConect = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner.add_spawnable_scene("res://Charaacter.tscn")
	spawner.spawn_function = SpawnPlayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if readyForConect == true:
		if multiplayer.is_server():
			spawner.spawn(multiplayer.get_unique_id())
			for peer in multiplayer.get_peers():
				
				spawner.spawn(peer)
		readyForConect = false

func SpawnPlayer(peer_id):
	var newPlayer = player.instantiate()
	newPlayer.position.y = 3
	newPlayer.name = str(peer_id)
	newPlayer.set_multiplayer_authority(peer_id)
	return newPlayer

func findaudioplayer():
	return $AudioStreamPlayer
