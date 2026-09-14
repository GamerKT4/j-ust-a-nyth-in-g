extends CanvasLayer

@onready var output: RichTextLabel = %Output

const WIN_HEADER = "Microsoft Windows [Version 10.0.19045.6466]\n(c) Microsoft Corporation. All rights reserved.\n\nC:\\WINDOWS\\system32>"

var dialogue: Array[Dictionary] = [
	{"cmd": " netstat -ano | findstr :8080\n", "speed": 0.04, "pause": 0.4},
	{"text": "  TCP    0.0.0.0:8080           0.0.0.0:0              LISTENING       4912\n\nC:\\WINDOWS\\system32>", "speed": 0.005, "pause": 0.8},
	{"cmd": " dev_remote_kill.bat --target player\n", "speed": 0.04, "pause": 0.7},
	{"text": "\n[REMOTE OVERRIDE CONNECTED]\n", "speed": 0.01, "pause": 0.5},
	{"text": "DEV: Hold on...\n", "speed": 0.06, "pause": 1.1},
	{"text": "DEV: You actually beat the waves?\n", "speed": 0.05, "pause": 1.3},
	{"text": "DEV: The level was tuned so you were supposed to die at wave 2.\n", "speed": 0.04, "pause": 1.5},
	{"text": "DEV: Give me a second, let me terminate this instance before you break the memory heap.\n\n", "speed": 0.04, "pause": 1.7},
	{"text": "C:\\WINDOWS\\system32>", "speed": 0.01, "pause": 0.4},
	{"cmd": " taskkill /F /IM swarm_defense_build.exe\n", "speed": 0.035, "pause": 0.8},
	{"text": "SUCCESS: The process \"swarm_defense_build.exe\" with PID 4912 has been terminated.\n", "speed": 0.01, "pause": 1.4}
]

var full_text: String = ""
var is_cursor_visible: bool = true
var cursor_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	if Variables.has_signal("game_won_triggered"):
		Variables.game_won_triggered.connect(start_cutscene)

func _process(delta: float) -> void:
	if not visible:
		return
		
	cursor_timer += delta
	if cursor_timer >= 0.45:
		cursor_timer = 0.0
		is_cursor_visible = !is_cursor_visible
		_refresh_display()

func start_cutscene() -> void:
	visible = true
	get_tree().paused = true
	
	full_text = WIN_HEADER
	_refresh_display()
	
	await get_tree().create_timer(1.0).timeout
	_run_script()

func _run_script() -> void:
	for line in dialogue:
		var txt = line.get("cmd", line.get("text", ""))
		var char_delay = line.get("speed", 0.03)
		var pause_after = line.get("pause", 0.5)

		for c in txt:
			full_text += c
			_refresh_display()
			await get_tree().create_timer(char_delay).timeout

		await get_tree().create_timer(pause_after).timeout

	# Shut down the game
	await get_tree().create_timer(0.8).timeout
	get_tree().quit()

func _refresh_display() -> void:
	output.text = full_text + ("█" if is_cursor_visible else " ")
