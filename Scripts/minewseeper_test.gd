extends TileMapLayer

@onready var window: ColorRect = %Window
@onready var game_settings: Button = %GameSettings
@onready var os = OS.get_name()

@export var CellColumns := 30
@export var CellRows := 16
@export var MineAmount := 99
var CurrCellColumns := CellColumns
var CurrCellRows := CellRows
var FlagAmount := 0
var GameEnded := false

var theme := 0

# -1 = empty
# 0 = mine
# 1-8 = number
var cells : Array[int]
var SurroundingCells : Array[int]
var SurroundingCellsIndex : Array[int]
var OffsetCoords : Vector2i


func _ready() -> void:
	SetUpBoard()

# Sets board with empty grid
func SetUpBoard() -> void:
	var WindowWidth = window.size.x
	var WindowHeight = window.size.y
	CurrCellColumns = CellColumns
	CurrCellRows = CellRows
	GameEnded = false
	cells = []
	FlagAmount = 0
	@warning_ignore("integer_division")
	self.position.x = WindowWidth/2 - CurrCellColumns/2 * 16
	@warning_ignore("integer_division")
	self.position.y = WindowHeight/2 - CurrCellRows/2 * 16 + 60
	self.clear()
	for  y in range(CurrCellRows):
		for x in range(CurrCellColumns):
			set_cell(Vector2i(x,y), theme, Vector2i(0,2), 0)
			cells.append(-1)

func SetUpMines(avoid : Vector2i) -> void:
	var temp := MineAmount
	if MineAmount > CurrCellColumns*CurrCellRows:
		temp = CurrCellColumns*CurrCellRows
	for i in range(temp):
		cells[i] = 0
	
	if MineAmount >= CurrCellColumns*CurrCellRows:
		pass
	
	elif MineAmount > CurrCellColumns*CurrCellRows - 9:
		var place := CurrCellColumns*CurrCellRows - MineAmount
		while cells.has(-1):
			cells.set(cells.find(-1), 0)
		GetSurroundingCells(avoid)
		for cell in range(place):
			SurroundingCells[cell] = -1
		SurroundingCells.shuffle()
		while SurroundingCells[4] == 0:
			SurroundingCells.shuffle()
		for cell in SurroundingCells.size():
			cells.set(GetCellSurroundingIndex(avoid)[cell], SurroundingCells[cell])
	
	elif MineAmount <= CurrCellColumns*CurrCellRows - 9:
		if GetSurroundingCells(avoid).has(-1):
				for cell in range(GetSurroundingCells(avoid).size()):
					if GetSurroundingCells(avoid)[cell] == -1:
						swap(GetCellSurroundingIndex(avoid)[cell], cells.find(0))
		var mines := GetSurroundingCells(avoid).count(0)
		for mine in mines:
			cells.set(cells.find(-1), 0)
		for cell in range(cells.size()-1, -1, -1):
			if GetCellSurroundingIndex(avoid).has(cell):
				cells.remove_at(cell)
		cells.shuffle()
		for cell in GetCellSurroundingIndex(avoid):
			if cell != -1:
				cells.insert(cell, -1)
			else:
				cells.insert(cell, 0)
	
	#Set Number Cells on Board
	for  y in range(CurrCellRows):
		for x in range(CurrCellColumns):
			if not cells[GetCellIndex(Vector2i(x,y))] == 0:
				var MineCount := 0
				for i in GetSurroundingCells(Vector2i(x,y)):
					if i == 0:
						MineCount += 1
				if MineCount > 0:
					cells[GetCellIndex(Vector2i(x,y))] = MineCount

func swap(a: int, b: int):
	var t = cells[a]
	cells[a] = cells[b]
	cells[b] = t

# Detect clicks on board cell
func _input(event: InputEvent) -> void:
	if not GameEnded:
		if event.is_action_pressed("reveal") and os != "iOS":
			var CellAtMouse : Vector2i = local_to_map(get_local_mouse_position())
			if GetAtlasCoords(CellAtMouse) != Vector2i(0,3) and GetAtlasCoords(CellAtMouse) != Vector2i(-1,-1):
				if cells.has(0):
					RevealCell(CellAtMouse)
					if cells[GetCellIndex(CellAtMouse)] == 0:
						GameEnded = true
						RevealAllMines(CellAtMouse)
				else:  
					SetUpMines(CellAtMouse)
					RevealCell(CellAtMouse)
					if cells[GetCellIndex(CellAtMouse)] == 0:
						GameEnded = true
						RevealAllMines(CellAtMouse)
		
		elif event.is_action_pressed("flag"):
			var CellAtMouse : Vector2i = local_to_map(get_local_mouse_position())
			#Swap unrevealed states
			if GetAtlasCoords(CellAtMouse) == Vector2i(0,2):
				set_cell(CellAtMouse, theme, Vector2i(0,3), 0)
				FlagAmount += 1
				game_settings.SetMineCount(MineAmount, FlagAmount)
			elif GetAtlasCoords(CellAtMouse) == Vector2i(0,3):
				set_cell(CellAtMouse, theme, Vector2i(0,2), 0)
				FlagAmount -= 1
				game_settings.SetMineCount(MineAmount, FlagAmount)

# Compute clicked cell
func RevealCell(CellCoords : Vector2i) -> void:
	var CellIndex : int = GetCellIndex(CellCoords)
	
	var AtlasCoords : Vector2i
	match cells[CellIndex]:
		-1: AtlasCoords = Vector2i(1,2)
		0: AtlasCoords = Vector2i(3,2)
		1: AtlasCoords = Vector2i(0,0)
		2: AtlasCoords = Vector2i(1,0)
		3: AtlasCoords = Vector2i(2,0)
		4: AtlasCoords = Vector2i(3,0)
		5: AtlasCoords = Vector2i(0,1)
		6: AtlasCoords = Vector2i(1,1)
		7: AtlasCoords = Vector2i(2,1)
		8: AtlasCoords = Vector2i(3,1)
	
	set_cell(CellCoords, theme, AtlasCoords, 0)
	
	if cells[CellIndex] == -1:
		RevealSurroundingCells(CellCoords)

# Converts CellCoords to index in Array
func GetCellIndex(CellCoords : Vector2i) -> int:
	if CellCoords.x < CurrCellColumns and CellCoords.y < CurrCellRows:
		if CellCoords.x >= 0 and CellCoords.y >= 0:
			return CellCoords.y * CurrCellColumns + CellCoords.x
		else:
			return -1
	else:
		return -1

func GetSurroundingCells(CellCoords : Vector2i) -> Array[int]:
	SurroundingCells = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			OffsetCoords = CellCoords + Vector2i(x,y)
			if GetCellIndex(OffsetCoords) > -1:
				SurroundingCells.append(cells[GetCellIndex(OffsetCoords)])
			else:
				SurroundingCells.append(-1)
	return SurroundingCells

func GetCellSurroundingIndex(CellCoords : Vector2i) -> Array[int]:
	SurroundingCellsIndex = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			OffsetCoords = CellCoords + Vector2i(x,y)
			SurroundingCellsIndex.append(GetCellIndex(OffsetCoords))
	return SurroundingCellsIndex

func RevealSurroundingCells(CellCoords : Vector2i) -> void:
	for y in range(-1,2):
		for x in range(-1,2):
			OffsetCoords = CellCoords + Vector2i(x,y)
			if GetCellIndex(OffsetCoords) > -1:
				#If Cell is empty or a flag or isnt revealed
				if GetAtlasCoords(OffsetCoords) == Vector2i(0,2) or GetAtlasCoords(OffsetCoords) == Vector2i(0,3):
					RevealCell(OffsetCoords)

func RevealAllMines(avoid : Vector2i) -> void:
	var CellCoords : Vector2i
	for  y in range(CurrCellRows):
		for x in range(CurrCellColumns):
			CellCoords = Vector2i(x,y)
			if cells[GetCellIndex(CellCoords)] == 0 and CellCoords != avoid and GetAtlasCoords(CellCoords) != Vector2i(0,3):
				set_cell(CellCoords, theme, Vector2i(2,2), 0)
			else:
				if GetAtlasCoords(CellCoords) == Vector2i(0,3) and cells[GetCellIndex(CellCoords)] != 0:
					set_cell(CellCoords, theme, Vector2i(1,3), 0)
				elif CellCoords == avoid:
					set_cell(CellCoords, theme, Vector2i(3,2), 0)

func GetAtlasCoords(CellCoords : Vector2i) -> Vector2i:
	return get_cell_atlas_coords(CellCoords)
