extends CanvasLayer

@export var optionButton : OptionButton

@export var paused = true
var timeRunning = false
@export var timerAudioPoll : Timer

var selectedIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	optionButton.item_selected.connect(ChangeAudioInput)
	timerAudioPoll.timeout.connect(UpdateAudioList)
	UpdateAudioList()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if paused == true and timeRunning == false:
		timerAudioPoll.start()
		timeRunning = true
	elif paused == false:
		timeRunning = false
		timerAudioPoll.stop()

func AudioServerChanged():
	print("LALSFA")

func ChangeAudioInput(index):
	AudioServer.input_device = optionButton.get_item_text(index)
	selectedIndex = index

func UpdateAudioList():
	optionButton.clear()
	for input in AudioServer.get_input_device_list():
		optionButton.add_item(input)
	optionButton.select(selectedIndex)
