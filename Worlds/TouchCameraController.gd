extends Camera2D

# https://www.youtube.com/watch?v=vnAkooGCLDA
# all but no rotate feature

var zoomSpeed: float = 0.1
var panSpeed: float = 1.0
var rotationSpeed: float = 1.0

var canPan: bool = true
var canZoom: bool = true

var startZoom: Vector2
var startDistance: float
var touchPoints: Dictionary = {}

func _input(event):
	if event is InputEventScreenTouch:
		handleTouch(event)
	elif event is InputEventScreenDrag:
		handleDrag(event)

func handleTouch(event: InputEventScreenTouch):
	if event.pressed:
		touchPoints[event.index] = event.position
	else:
		touchPoints.erase(event.index)
	
	if touchPoints.size() == 2:
		var touchPointPositions = touchPoints.values()
		startDistance = touchPointPositions[0].distance_to(touchPointPositions[1])
		
		startZoom = zoom
	elif touchPoints.size() < 2:
		startDistance = 0

func handleDrag(event: InputEventScreenDrag):
	touchPoints[event.index] = event.position
	
	if touchPoints.size() == 1:
		if canPan:
			offset -= event.relative * panSpeed / zoom.x # normalize depending on zoom
	
	elif touchPoints.size() == 2:
		var touchPointPositions = touchPoints.values()
		var currentDist = touchPointPositions[0].distance_to(touchPointPositions[1])
		
		var zoomFactor = startDistance / currentDist
		if canZoom:
			zoom = startZoom / zoomFactor
		
		# max dist u can go away from the screen is 1
		zoom.x = clamp(zoom.x, 1, 10)
		zoom.y = clamp(zoom.y, 1, 10)
		

