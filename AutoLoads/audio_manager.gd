extends Node

const OPUS_SAMPLE_RATE = 48000
const OPUS_CHANNELS = 2
const OPUS_FRAME_SIZE = 960
const OPUS_FRAME_DURATION = 20.0
const OPUS_BITRATE = 64000
const OPUS_COMPLEXITY = 10

var opusencoder: TwovoipOpusEncoder = TwovoipOpusEncoder.new()

var encode_accumulator := 0.0

@export var voipSpeaker : VoipSpeaker


func _ready() -> void:
	var err = AudioServer.set_input_device_active(true)
	print("Mic activation result: ", err)

	opusencoder.create_sampler(
		AudioServer.get_input_mix_rate(),
		OPUS_SAMPLE_RATE,
		OPUS_CHANNELS,
		false
	)

	opusencoder.create_opus_encoder(
		OPUS_BITRATE,
		OPUS_COMPLEXITY,
		true
	)

	print("Input mix rate: ", AudioServer.get_input_mix_rate())

	if multiplayer.is_server():
		StartVoiceStream(multiplayer.get_unique_id())
	else:
		SendVoiceStart.rpc_id(1)


func _process(delta: float) -> void:
	encode_accumulator += delta

	while encode_accumulator >= OPUS_FRAME_DURATION / 1000.0:
		encode_accumulator -= OPUS_FRAME_DURATION / 1000.0
		ProcessMicrophoneFrame()


func ProcessMicrophoneFrame() -> void:
	var opusPacket = CreateVoicePacket()

	if opusPacket.is_empty():
		return

	if multiplayer.is_server():
		RelayVoicePacket(opusPacket, multiplayer.get_unique_id())
	else:
		SendVoicePacket.rpc_id(1, opusPacket)


func CreateVoicePacket() -> PackedByteArray:
	var inputSize = opusencoder.calc_audio_chunk_size(OPUS_FRAME_SIZE)
	var audioChunk = AudioServer.get_input_frames(inputSize)

	if audioChunk.size() < OPUS_FRAME_SIZE:
		return PackedByteArray()

	opusencoder.process_pre_encoded_chunk(
		audioChunk,
		OPUS_FRAME_SIZE,
		false,
		false
	)

	return opusencoder.encode_chunk(PackedByteArray(), 1.0)


@rpc("any_peer", "reliable")
func SendVoiceStart() -> void:
	if not multiplayer.is_server():
		return

	var senderId = multiplayer.get_remote_sender_id()

	StartVoiceStream(senderId)


func StartVoiceStream(senderId: int) -> void:
	var header = {
		"talkingtimestart": Time.get_ticks_msec(),
		"opussamplerate": OPUS_SAMPLE_RATE,
		"opuschannels": OPUS_CHANNELS,
		"lenchunkprefix": 0,
		"opusstreamcount": 0,
		"opusframesize": OPUS_FRAME_SIZE,
		"opusframecount": 0
	}

	var headerPacket = JSON.stringify(header).to_ascii_buffer()

	# If the host is the sender, send the header to every client.
	if multiplayer.is_server() and senderId == multiplayer.get_unique_id():
		for peerId in multiplayer.get_peers():
			ReceiveVoicePacket.rpc_id(peerId, headerPacket)

	# If a client is the sender, send the header to the host.
	else:
		ReceiveVoicePacket(headerPacket)

		# Also send it to every other client.
		for peerId in multiplayer.get_peers():
			if peerId != senderId:
				ReceiveVoicePacket.rpc_id(peerId, headerPacket)


@rpc("any_peer", "unreliable")
func SendVoicePacket(opusPacket: PackedByteArray) -> void:
	if not multiplayer.is_server():
		return

	var senderId = multiplayer.get_remote_sender_id()

	RelayVoicePacket(opusPacket, senderId)


func RelayVoicePacket(opusPacket: PackedByteArray, senderId: int) -> void:
	# If the sender is a client, the host needs to receive
	# the packet locally.
	if senderId != multiplayer.get_unique_id():
		ReceiveVoicePacket(opusPacket)

	# Send the packet to every client except the sender.
	for peerId in multiplayer.get_peers():
		if peerId != senderId:
			ReceiveVoicePacket.rpc_id(peerId, opusPacket)


@rpc("authority", "unreliable")
func ReceiveVoicePacket(packet: PackedByteArray) -> void:
	voipSpeaker.tv_incomingaudiopacket(packet)
