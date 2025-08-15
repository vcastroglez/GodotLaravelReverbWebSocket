extends Node

var socket = WebSocketPeer.new()
var connected = false

func _ready():
	var app_key = getVar('reverb_app_key')
	# Connect to Laravel Reverb WebSocket server
	var url = "ws://localhost:8080/app/"+app_key
	var error = socket.connect_to_url(url)
	
	if error != OK:
		print("Failed to connect to WebSocket server: ", error)
	else:
		print("Attempting to connect to: ", url)
		

func _process(delta):
	socket.poll()
	
	var state = socket.get_ready_state()
	
	# Check connection state
	if state == WebSocketPeer.STATE_OPEN and not connected:
		connected = true
		print("WebSocket connected successfully!")
		
		# Send initial handshake/authentication if needed
		socket.send_text('{"event":"pusher:subscribe","data":{"channel":"your-channel"}}')
		
	elif state == WebSocketPeer.STATE_CLOSED:
		if connected:
			print("WebSocket connection closed")
			connected = false
	
	# Listen for incoming messages
	while socket.get_available_packet_count() > 0:
		var packet = socket.get_packet()
		var message = packet.get_string_from_utf8()
		print("Received: ", message)
		
		# Optional: Parse JSON if needed
		var json = JSON.new()
		var parse_result = json.parse(message)
		if parse_result == OK:
			var data = json.data
			print("Parsed data: ", data)

func _exit_tree():
	if connected:
		socket.close()
		print("WebSocket connection closed on exit")

func getVar(key):
	var file = "res://ecosystem.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict[key]
