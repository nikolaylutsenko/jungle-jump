extends Node2D

signal score_changed

@export var opossum : PackedScene


var item_scene = load("res://items/item.tscn")
var score = 0 : set = set_score
func set_score(value):
	score = value
	score_changed.emit(score)


func spawn_items():
	var item_cells = $Items.get_used_cells(0)
	for cell in item_cells:
		var data = $Items.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		var item = item_scene.instantiate()
		add_child(item)
		item.init(type, $Items.map_to_local(cell))
		item.picked_up.connect(self._on_item_picked_up)


func _on_item_picked_up():
	score += 1


# Called when the node enters the scene tree for the first time.
func _ready():
	$Items.hide()
	var s_point = $SpawnPoint.position
	$Player.reset(s_point)
	set_camera_limits()
	spawn_items()


func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.tile_set.tile_size
	#$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	#$Player/Camera2D.limit_right = (map_size.position.x + 5) * cell_size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# fun - instantiate new enemie
#func _on_button_pressed():
#		var op = opossum.instantiate()
#		get_tree().root.add_child(op)
#		var op_possition = $OpPosition.transform
#		op.start(op_possition)
