class_name Game
extends TileMap

var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i := [i_0, i_90, i_180, i_270]

var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

var s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

var l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

var j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

var shapes := [i, t, o, z, s, l, j]
var shapes_full := shapes.duplicate()

var is_paused : bool = false
var pause_screen : Control

const COLS : int = 10
const ROWS : int = 20

const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
const start_pos := Vector2i(5, 1)
var cur_pos : Vector2i
var speed : float
const ACCEL : float = 0.1

var piece_type
var next_piece_type
var rotation_index : int = 0
var active_piece : Array

var score : int
var best_score : int = 0  
const REWARD : int = 100
var game_running : bool

var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

var board_layer : int = 0
var active_layer : int = 1

var preview_layer : int = 2  
var cell_size: int = 32  

func _ready():
	new_game()
	$HUD.get_node("StartButton").pressed.connect(new_game)

func new_game():
	var background_music = $BackgroundMusic
	background_music.play()
	best_score = load_high_score()

	score = 0
	$HUD.get_node("ScoreLabel").text = "Счёт: " + str(score)
	$HUD.get_node("BestScoreLabel").text = "Лучший результат: " + str(best_score)
	speed = 1.0
	game_running = true
	steps = [0, 0, 0]
	$HUD.get_node("GameOverLabel").hide()

	clear_piece()
	clear_board()
	clear_panel()
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	create_piece()

func _process(_delta):
	if Input.is_action_just_pressed("ui_pause"):
		toggle_pause()
	
	if not is_paused and game_running:
		if Input.is_action_pressed("ui_left"):
			steps[0] += 10
		elif Input.is_action_pressed("ui_right"):
			steps[1] += 10
		elif Input.is_action_pressed("ui_down"):
			steps[2] += 10

		if Input.is_action_just_pressed("ui_up"):
			rotate_piece()
		elif Input.is_action_just_pressed("ui_drop"):
			drop_piece()  

		steps[2] += speed
		for ih in range(steps.size()):
			if steps[ih] > steps_req:
				move_piece(directions[ih])
				steps[ih] = 0
				
		
func toggle_pause():	
	is_paused = not is_paused

func pick_piece():
	var piece
	if not shapes.is_empty():
		shapes.shuffle()
		piece = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		shapes.shuffle()
		piece = shapes.pop_front()
	return piece

func create_piece():
	steps = [0, 0, 0] 
	cur_pos = start_pos
	active_piece = piece_type[rotation_index]
	draw_piece(active_piece, cur_pos, piece_atlas)
	clear_piece()
	draw_piece(next_piece_type[0], Vector2i(15, 6), next_piece_atlas)

func clear_piece():
	for it in active_piece:
		erase_cell(active_layer, cur_pos + it)

func draw_piece(piece, pos, atlas):
	for ih in piece:
		set_cell(active_layer, pos + ih, tile_id, atlas)

func drop_piece():
	while can_move(Vector2i.DOWN):
		move_piece(Vector2i.DOWN) 
	land_piece()  
	check_rows()  
	piece_type = next_piece_type
	piece_atlas = next_piece_atlas
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	clear_panel()
	create_piece()
	check_game_over()

func rotate_piece():
	clear_piece()
	var temp_rotation_index = (rotation_index + 1) % 4
	var rotated_piece = piece_type[temp_rotation_index]

	if can_rotate():
		rotation_index = temp_rotation_index
		active_piece = rotated_piece
	else:
		var shifted_left = can_move(Vector2i.LEFT)
		if shifted_left:
			cur_pos += Vector2i.LEFT
			if can_rotate():
				rotation_index = temp_rotation_index
				active_piece = rotated_piece
		else:
			var shifted_right = can_move(Vector2i.RIGHT)
			if shifted_right:
				cur_pos += Vector2i.RIGHT
				if can_rotate():
					rotation_index = temp_rotation_index
					active_piece = rotated_piece
	if piece_type == i:
		if not can_rotate():
			cur_pos += Vector2i.RIGHT
			if can_rotate():
				rotation_index = temp_rotation_index
				active_piece = rotated_piece
	draw_piece(active_piece, cur_pos, piece_atlas)


func move_piece(dir):
	if can_move(dir):
		clear_piece()
		cur_pos += dir
		draw_piece(active_piece, cur_pos, piece_atlas)
	else:
		if dir == Vector2i.DOWN:
			land_piece()
			check_rows()
			piece_type = next_piece_type
			piece_atlas = next_piece_atlas
			next_piece_type = pick_piece()
			next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
			clear_panel()
			create_piece()
			check_game_over()

func can_move(dir):
	var cm = true
	for iu in active_piece:
		if not is_free(iu + cur_pos + dir):
			cm = false
	return cm

func can_rotate():
	var cr = true
	var temp_rotation_index = (rotation_index + 1) % 4
	for im in piece_type[temp_rotation_index]:
		if not is_free(im + cur_pos):
			cr = false
	return cr

func is_free(pos):
	return get_cell_source_id(board_layer, pos) == -1

func land_piece():
	for iv in active_piece:
		erase_cell(active_layer, cur_pos + iv)
		set_cell(board_layer, cur_pos + iv, tile_id, piece_atlas)
func clear_panel():
	for ii in range(14, 19):
		for jb in range(5, 9):
			erase_cell(active_layer, Vector2i(ii, jb))

func load_high_score() -> int:
	var config = ConfigFile.new()
	var err = config.load("user://user_data.cfg")
	if err == OK:
		return config.get_value("game", "high_score", 0)
	return 0

func save_high_score(score: int):
	var config = ConfigFile.new()
	config.set_value("game", "high_score", score)
	config.save("user://user_data.cfg")

func check_rows():
	var row : int = ROWS
	while row > 0:
		var count = 0
		for ip in range(COLS):
			if not is_free(Vector2i(ip + 1, row)):
				count += 1
		if count == COLS:
			shift_rows(row)
			score += REWARD
			$HUD.get_node("ScoreLabel").text = "Счёт: " + str(score)
			speed += ACCEL
			var line_sound = $LineSound
			line_sound.play()
		else:
			row -= 1
		if score > best_score:
				best_score = score
				save_high_score(best_score)
				$HUD.get_node("BestScoreLabel").text = "Лучший результат: " + str(best_score)
				
func shift_rows(row):
	var atlas
	for zi in range(row, 1, -1):
		for jx in range(COLS):
			atlas = get_cell_atlas_coords(board_layer, Vector2i(jx + 1, zi - 1))
			if atlas == Vector2i(-1, -1):
				erase_cell(board_layer, Vector2i(jx + 1, zi))
			else:
				set_cell(board_layer, Vector2i(jx + 1, zi), tile_id, atlas)

func clear_board():
	for iv in range(ROWS):
		for jj in range(COLS):
			erase_cell(board_layer, Vector2i(jj + 1, iv + 1))

func check_game_over():
	for im in active_piece:
		if not is_free(im + cur_pos):
			var background_music = $BackgroundMusic
			var game_over_sound = $GameOverSound
			game_over_sound.play()
			land_piece()
			$HUD.get_node("GameOverLabel").show()
			game_running = false
			background_music.stop()


func _on_background_music_finished():
	var background_music = $BackgroundMusic
	background_music.play()
