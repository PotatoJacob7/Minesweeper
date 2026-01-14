extends Button

@onready var minesweeper: TileMapLayer = %Minesweeper
@onready var item_list: ItemList = %ItemList
@onready var bg: TileMapLayer = %BG
@onready var window: ColorRect = %Window
@onready var label: Label = $Label
@onready var settings: Control = %Settings
@onready var settings_layer: Node2D = %SettingsLayer
@onready var mine_count_layer: TileMapLayer = %MineCountLayer
@onready var rows_layer: TileMapLayer = %RowsL
@onready var columns_layer: TileMapLayer = %ColumnsL
@onready var rows: LineEdit = %Rows
var RowsText := ""
@onready var columns: LineEdit = %Columns
var ColumnsText := ""

@onready var WindowWidth = window.size.x
@onready var WindowHeight = window.size.y
@onready var MaxColumns := int(WindowWidth/16)
@warning_ignore("integer_division")
@onready var MaxRows := int(WindowHeight/16.0 - int(125/16))

var ThemeId:= 0
var ThemeList := [
	"Def_Light",
	"Def_Dark",
	"UT",
	"Min_Light",
	"Min_Dark",
	"ILLIT",
	
]

func _ready() -> void:
	columns.text_changed.connect(filter.bind(ColumnsText, columns))
	columns.text_submitted.connect(SetColumns)
	rows.text_changed.connect(filter.bind(RowsText, rows))
	rows.text_submitted.connect(SetRows)
	@warning_ignore("integer_division")
	self.position.x = WindowWidth/2 - 11
	@warning_ignore("integer_division")
	self.position.y = minesweeper.position.y - 28
	SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)
	SetColumnsCount(minesweeper.CellColumns)
	SetRowsCount(minesweeper.CellRows)
	RowsText = str(minesweeper.CellRows)
	ColumnsText = str(minesweeper.CellColumns)

func SetButton() -> void:
	@warning_ignore("integer_division")
	self.position.y = minesweeper.position.y - 28

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				SetButton()
				minesweeper.SetUpBoard()
				SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)
			MOUSE_BUTTON_RIGHT:
				SetButton()
				if item_list.item_count == 0:
					LoadThemes()
				OpenThemes()
			MOUSE_BUTTON_MIDDLE:
				SetButton()
				OpenGameSettings()

func SetLayer(layer: TileMapLayer, arr: Array) -> void:
	layer.clear()
	for item in range(arr.size()):
		var AtlasCoords : Vector2i
		match arr[item]:
			-1: AtlasCoords = Vector2i(-1,-1)
			0: AtlasCoords = Vector2i(4,0)
			1: AtlasCoords = Vector2i(4,1)
			2: AtlasCoords = Vector2i(4,2)
			3: AtlasCoords = Vector2i(4,3)
			4: AtlasCoords = Vector2i(4,4)
			5: AtlasCoords = Vector2i(5,0)
			6: AtlasCoords = Vector2i(5,1)
			7: AtlasCoords = Vector2i(5,2)
			8: AtlasCoords = Vector2i(5,3)
			9: AtlasCoords = Vector2i(5,4)
		layer.set_cell(Vector2(item,0), ThemeId, AtlasCoords, 0)

func SetMineCount(MAmount: int, FAmount: int) -> void:
	var digits := IntToArray(MAmount - FAmount)
	digits = OrderArray(digits, str(minesweeper.MineAmount).length())
	mine_count_layer.position = self.global_position
	mine_count_layer.position.x -= digits.size()*16+5
	mine_count_layer.position.y += 3
	SetLayer(mine_count_layer, digits)

func SetColumnsCount(amount: int) -> void:
	var digits := IntToArray(amount)
	digits = OrderArray(digits, 3)
	columns_layer.position.x = columns.global_position.x + 3
	columns_layer.position.y = columns.global_position.y + 3
	SetLayer(columns_layer, digits)

func SetColumns(string: String):
	if int(string) > MaxColumns:
		ColumnsText = str(MaxColumns)
		columns.text = ColumnsText
		minesweeper.CellColumns = MaxColumns
		string = str(MaxColumns)
	else:
		minesweeper.CellColumns = int(string)
	SetMines(str(minesweeper.CellColumns*minesweeper.CellRows*0.2))
	minesweeper.SetUpBoard()
	SetButton()
	SetColumnsCount(int(string))
	SetRowsCount(int(RowsText))
	SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)

func SetRowsCount(amount: int) -> void:
	var digits := IntToArray(amount)
	digits = OrderArray(digits, 2)
	rows_layer.position.x = rows.global_position.x + 3.1525
	rows_layer.position.y = rows.global_position.y + 3
	SetLayer(rows_layer, digits)

func SetRows(string: String):
	if int(string) > MaxRows:
		RowsText = str(MaxRows)
		rows.text = RowsText
		minesweeper.CellRows = MaxRows
		string = str(MaxRows)
	else:
		minesweeper.CellRows = int(string)
	SetMines(str(minesweeper.CellColumns*minesweeper.CellRows*0.2))
	minesweeper.SetUpBoard()
	SetButton()
	SetColumnsCount(int(ColumnsText))
	SetRowsCount(int(string))
	SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)


func SetMines(string: String):
	minesweeper.MineAmount = int(string)

func filter(LText: String, PrevText: String, LEdit: LineEdit):
	if LText.is_empty() or LText.is_valid_int():
		PrevText = LText
	else:
		LEdit.text = PrevText
	
	match LEdit:
		columns: 
			SetColumnsCount(int(PrevText))
			ColumnsText = PrevText
		rows: 
			SetRowsCount(int(PrevText))
			RowsText = PrevText

func IntToArray(temp) -> Array:
	var arr := []
	for c in str(temp):
		arr.append(int(c))
	return arr

func OrderArray(temp: Array, ReqLength: int) -> Array:
	var UArray = temp #Unordered
	var OArray = [] #Ordered
	var TArray = [] #Temp
	while UArray.size() < ReqLength:
		UArray.append(-1)
	for item in UArray:
		if item == -1:
			OArray.append(-1)
		else:
			TArray.append(item)
	OArray.append_array(TArray)
	return OArray

func OpenThemes():
	item_list.visible = !item_list.visible

func LoadThemes():
	for style in ThemeList:
		item_list.add_icon_item(ResourceLoader.load("res://Assets/" + style + ".png"), true)

func OpenGameSettings():
	settings.visible = !settings.visible
	settings_layer.visible = !settings_layer.visible

func _on_item_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		ThemeId = index
		self.theme = ResourceLoader.load("res://Themes/" + ThemeList[index] + ".tres")
		label.theme = ResourceLoader.load("res://Themes/" + ThemeList[index] + ".tres")
		minesweeper.theme = index
		minesweeper.SetUpBoard()
		SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)
		SetColumnsCount(int(ColumnsText))
		SetRowsCount(int(RowsText))
		for y in range(0,69):
			for x in range(0,121):
				bg.set_cell(Vector2i(x,y), index, Vector2i(2,3), 0)
