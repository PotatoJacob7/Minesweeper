extends TileMapLayer
class_name MineSweeper

@onready var game_settings: GameSettings = %GameSettings

@export var CellColumns := 30
@export var CellRows := 16
@export var MineAmount := 99
var CurrCellColumns := CellColumns
var CurrCellRows := CellRows
var InitMineAmount := 99
var FlagAmount := 0
var GameEnded := false

var theme := 0

# -2 = flag
# -1 = empty
# 0 = mine
# 1-8 = number
enum CellType {FLAG = -3, UNOPENED, EMPTY, MINE, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT,}
var CellTypeCoords := {
					-3: Vector2i(5,1),
					-2: Vector2i(0,2),
					-1: Vector2i(0,1), 
					0: Vector2i(5,4), 
					1: Vector2i(1,1), 
					2: Vector2i(2,1),
					3: Vector2i(3,1), 
					4: Vector2i(4,1), 
					5: Vector2i(1,2), 
					6: Vector2i(2,2), 
					7: Vector2i(3,2), 
					8: Vector2i(4,2),
					}

var cells : Array[int]
var SurroundingCells : Array[int]
var SurroundingCellsIndex : Array[int]
var OffsetCoords : Vector2i
var LastMove : Array[Vector2i]


func _ready() -> void:
	SetUpBoard()

# Sets board with empty grid
func SetUpBoard() -> void:
	var WindowWidth = get_window().size.x
	var WindowHeight = get_window().size.y
	CurrCellColumns = CellColumns
	CurrCellRows = CellRows
	GameEnded = false
	cells = []
	FlagAmount = 0
	InitMineAmount = MineAmount
	@warning_ignore("integer_division")
	self.position.x = WindowWidth/2 - CurrCellColumns/2 * 16
	@warning_ignore("integer_division")
	self.position.y = WindowHeight/2 - CurrCellRows/2 * 16 + 60
	self.clear()
	for  y in range(CurrCellRows):
		for x in range(CurrCellColumns):
			set_cell(Vector2i(x,y), theme, CellTypeCoords[CellType.UNOPENED], 0)
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
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			game_settings.SetIcon(game_settings.IconType.CLICK)
		else:
			game_settings.SetIcon(game_settings.IconType.IDLE)
		
		if event.is_action_pressed("reveal"):
			var CellAtMouse : Vector2i = local_to_map(get_local_mouse_position())
			LastMove = []
			if GetAtlasCoords(CellAtMouse) != CellTypeCoords[CellType.FLAG] and GetAtlasCoords(CellAtMouse) != Vector2i(-1,-1):
				if cells.has(0):
					LastMove.append(CellAtMouse)
					
					if cells[GetCellIndex(CellAtMouse)] >= 1 and GetAtlasCoords(CellAtMouse) != CellTypeCoords[CellType.UNOPENED]:
						RevealSurroundingCells(CellAtMouse, false)
					
					RevealCell(CellAtMouse)
					
					for i in LastMove:
						if cells[GetCellIndex(i)] == 0:
							GameEnded = true
							game_settings.SetIcon(game_settings.IconType.LOST)
							RevealAllMines(LastMove)
				else:  
					SetUpMines(CellAtMouse)
					RevealCell(CellAtMouse)
					if cells[GetCellIndex(CellAtMouse)] == 0:
						GameEnded = true
						RevealAllMines(LastMove)
		
		if event.is_action_pressed("flag"):
			var CellAtMouse : Vector2i = local_to_map(get_local_mouse_position())
			#Swap unrevealed states
			if GetAtlasCoords(CellAtMouse) == CellTypeCoords[CellType.UNOPENED]:
				set_cell(CellAtMouse, theme, CellTypeCoords[CellType.FLAG], 0)
			elif GetAtlasCoords(CellAtMouse) == CellTypeCoords[CellType.FLAG]:
				set_cell(CellAtMouse, theme, CellTypeCoords[CellType.UNOPENED], 0)
		
		
		SetFlaggedCells()
		game_settings.SetMineCount(MineAmount, FlagAmount)

# Compute clicked cell
func RevealCell(CellCoords : Vector2i) -> void:
	var CellIndex : int = GetCellIndex(CellCoords)
	
	var AtlasCoords : Vector2i
	match cells[CellIndex]:
		-1: AtlasCoords = CellTypeCoords[CellType.EMPTY]
		0: AtlasCoords = CellTypeCoords[CellType.MINE]
		1: AtlasCoords = CellTypeCoords[CellType.ONE]
		2: AtlasCoords = CellTypeCoords[CellType.TWO]
		3: AtlasCoords = CellTypeCoords[CellType.THREE]
		4: AtlasCoords = CellTypeCoords[CellType.FOUR]
		5: AtlasCoords = CellTypeCoords[CellType.FIVE]
		6: AtlasCoords = CellTypeCoords[CellType.SIX]
		7: AtlasCoords = CellTypeCoords[CellType.SEVEN]
		8: AtlasCoords = CellTypeCoords[CellType.EIGHT]
	
	set_cell(CellCoords, theme, AtlasCoords, 0)
	
	if cells[CellIndex] == -1:
		RevealSurroundingCells(CellCoords, false)

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

func RevealSurroundingCells(CellCoords : Vector2i, CanReveal : bool) -> void:
	var NumFlags := 0
	for y in range(-1,2):
		for x in range(-1,2):
			OffsetCoords = CellCoords + Vector2i(x,y)
			if GetCellIndex(OffsetCoords) > -1:
				#Number Cell
				if cells[GetCellIndex(CellCoords)] >= 1:
					#Flagged cells
					if GetAtlasCoords(OffsetCoords) == CellTypeCoords[CellType.FLAG]:
						if not CanReveal:
							NumFlags += 1
					else:
						if CanReveal:
							if GetAtlasCoords(OffsetCoords) == CellTypeCoords[CellType.UNOPENED]:
								LastMove.append(OffsetCoords)
								RevealCell(OffsetCoords)
				else:
					#If Cell is empty or a flag or isnt revealed
					if GetAtlasCoords(OffsetCoords) == CellTypeCoords[CellType.UNOPENED] or GetAtlasCoords(OffsetCoords) == CellTypeCoords[CellType.FLAG]:
						RevealCell(OffsetCoords)
	if cells[GetCellIndex(CellCoords)] >= 1:
		#Number Cell
		if NumFlags == cells[GetCellIndex(CellCoords)]:
			RevealSurroundingCells(CellCoords, true)

func RevealAllMines(avoid : Array[Vector2i]) -> void:
	var CellCoords : Vector2i
	for  y in range(CurrCellRows):
		for x in range(CurrCellColumns):
			CellCoords = Vector2i(x,y)
			if cells[GetCellIndex(CellCoords)] == 0:
				if GetAtlasCoords(CellCoords) == CellTypeCoords[CellType.FLAG]:
					set_cell(CellCoords, theme, CellTypeCoords[CellType.FLAG], 0)
				elif not avoid.has(CellCoords):
					set_cell(CellCoords, theme, Vector2i(5,3), 0)#unclicked mine
			else:
				if get_cell_atlas_coords(CellCoords) == CellTypeCoords[CellType.FLAG]:
					set_cell(CellCoords, theme, Vector2i(5,2), 0)#wrong flag

func SetFlaggedCells():
	FlagAmount = 0
	for  y in range(CurrCellRows):
		for x in range(CurrCellColumns):
			var CellCoords = Vector2i(x,y)
			if GetAtlasCoords(CellCoords) == CellTypeCoords[CellType.FLAG]:
				FlagAmount += 1

func GetAtlasCoords(CellCoords : Vector2i) -> Vector2i:
	return get_cell_atlas_coords(CellCoords)
