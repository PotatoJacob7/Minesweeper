extends Button
class_name GameSettings

@onready var minesweeper: MineSweeper = %Minesweeper
@onready var item_list: ItemList = %ItemList
@onready var bg: TileMapLayer = %BG
@onready var texture_rect: TextureRect = $TextureRect
@onready var settings: Control = %Settings
@onready var settings_layer: Node2D = %SettingsLayer
@onready var mine_count_layer: TileMapLayer = %MineCountLayer
@onready var rows_layer: TileMapLayer = %RowsL
@onready var columns_layer: TileMapLayer = %ColumnsL
@onready var backing: Panel = %Backing
@onready var bg_button: Button = %"Bg Button"
@onready var rows: LineEdit = %Rows
var RowsText := ""
@onready var columns: LineEdit = %Columns
var ColumnsText := ""

@onready var camera_manger: CamManager = %CameraManger

@onready var WindowWidth = get_window().size.x
@onready var WindowHeight = get_window().size.y
@onready var MaxColumns := int(WindowWidth/16.0)
@onready var MaxRows := int(WindowHeight/16.0 - int(125.0/16.0))

var UiTheme := Theme.new()
var ThemeId:= 0
var ThemeList := [
	"Def_Light",
	"Def_Dark",
	"Min_Light",
	"Min_Dark",
	"Min_Max_Light",
	"Min_Max_Dark",
	"ILLIT",
	"UT",
]

enum IconType {IDLE, CLICK, LOST, WON}
var icons := {
	0: Rect2(16.0, 0.0, 16.0, 16.0),
	1: Rect2(32.0, 0.0, 16.0, 16.0),
	2: Rect2(48.0, 0.0, 16.0, 16.0),
	3: Rect2(64.0, 0.0, 16.0, 16.0),
}

func _ready() -> void:
	columns.text_changed.connect(filter.bind(ColumnsText, columns))
	columns.text_submitted.connect(SetColumns)
	rows.text_changed.connect(filter.bind(RowsText, rows))
	rows.text_submitted.connect(SetRows)
	item_list.mouse_entered.connect(SetScroll)
	item_list.mouse_exited.connect(SetScroll)
	@warning_ignore("integer_division")
	self.position.x = WindowWidth/2 - 11
	@warning_ignore("integer_division")
	self.position.y = minesweeper.position.y - 27
	LoadThemes()
	SetTheme()
	SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)
	SetColumnsCount(minesweeper.CellColumns)
	SetRowsCount(minesweeper.CellRows)
	SetBacking(backing)
	SetBg()
	RowsText = str(minesweeper.CellRows)
	ColumnsText = str(minesweeper.CellColumns)

func SetScroll():
	camera_manger.CanScroll = !camera_manger.CanScroll

func SetButton() -> void:
	@warning_ignore("integer_division")
	self.position.y = minesweeper.position.y - 27

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				SetButton()
				minesweeper.SetUpBoard()
				SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)
			MOUSE_BUTTON_RIGHT:
				SetButton()
				OpenGameSettings()

func SetBacking(panel: Panel):
	panel.position = minesweeper.global_position - Vector2(3.0, 3.0)
	panel.size.x = minesweeper.CellColumns*16 + 6
	panel.size.y = minesweeper.CellRows*16 + 6

func SetLayer(layer: TileMapLayer, arr: Array) -> void:
	layer.clear()
	for item in range(arr.size()):
		var AtlasCoords : Vector2i
		match arr[item]:
			-1: AtlasCoords = Vector2i(0,3)
			0: AtlasCoords = Vector2i(0,3)
			1: AtlasCoords = Vector2i(1,3)
			2: AtlasCoords = Vector2i(2,3)
			3: AtlasCoords = Vector2i(3,3)
			4: AtlasCoords = Vector2i(4,3)
			5: AtlasCoords = Vector2i(0,4)
			6: AtlasCoords = Vector2i(1,4)
			7: AtlasCoords = Vector2i(2,4)
			8: AtlasCoords = Vector2i(3,4)
			9: AtlasCoords = Vector2i(4,4)
		layer.set_cell(Vector2i(item,0), ThemeId, AtlasCoords, 0)

func SetMineCount(MAmount: int, FAmount: int) -> void:
	var digits := IntToArray(MAmount - FAmount)
	digits = OrderArray(digits, str(minesweeper.InitMineAmount).length())
	mine_count_layer.position = self.global_position
	mine_count_layer.position.x -= digits.size()*16+5
	mine_count_layer.position.y += 3
	SetLayer(mine_count_layer, digits)

func SetColumnsCount(amount: int) -> void:
	var digits := IntToArray(amount)
	digits = OrderArray(digits, 3)
	columns_layer.position = columns.global_position + Vector2(3.0, 3.0)
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
	SetBacking(backing)
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
	SetBacking(backing)
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

func LoadThemes():
	var tileSet := TileSet.new()
	minesweeper.tile_set = tileSet
	mine_count_layer.tile_set = tileSet
	columns_layer.tile_set = tileSet
	rows_layer.tile_set = tileSet
	for style in ThemeList:
		var atlas := TileSetAtlasSource.new()
		atlas.texture = ResourceLoader.load("res://Assets/" + style + ".png")
		for y in atlas.get_atlas_grid_size().y:
			for x in atlas.get_atlas_grid_size().x:
				var coords := Vector2i(x,y)
				atlas.create_tile(coords)
		minesweeper.tile_set.add_source(atlas, ThemeList.find(style))
		bg.tile_set = minesweeper.tile_set
		item_list.add_icon_item(ResourceLoader.load("res://Assets/" + style + ".png"), true)
		

func OpenGameSettings():
	settings.visible = !settings.visible
	settings_layer.visible = !settings_layer.visible
	item_list.visible = !item_list.visible

func _on_bg_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				bg.visible = !bg.visible
				var window = get_window()
				window.borderless = !window.borderless
				window.size = Vector2(1920, 1080)
				window.mode = Window.MODE_WINDOWED

func _on_item_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		ThemeId = index
		SetTheme()
		self.theme = UiTheme
		backing.theme = UiTheme
		minesweeper.theme = index
		minesweeper.SetUpBoard()
		SetIcon(IconType.IDLE)
		SetMineCount(minesweeper.MineAmount, minesweeper.FlagAmount)
		SetColumnsCount(int(ColumnsText))
		SetRowsCount(int(RowsText))
		SetBg()

func SetBg():
	for y in range(0,69):
			for x in range(0,121):
				bg.set_cell(Vector2i(x,y), ThemeId, Vector2i(5, 0), 0)

func SetIcon(type: IconType):
	var IconAtlas = AtlasTexture.new()
	IconAtlas.region = icons[type]
	IconAtlas.atlas = ResourceLoader.load("res://Assets/" + ThemeList[ThemeId] + ".png")
	texture_rect.texture = IconAtlas

func SetTheme():
	var BgAtlas = AtlasTexture.new()
	BgAtlas.region = Rect2(0.0, 0.0, 16.0, 16.0)
	BgAtlas.atlas = ResourceLoader.load("res://Assets/" + ThemeList[ThemeId] + ".png")
	bg_button.icon = BgAtlas
	
	UiTheme.set_color("caret_color", "LineEdit", Color(1.0, 1.0, 1.0, 0.0))
	UiTheme.set_font_size("font_size", "LineEdit", 8)
	
	var empty := StyleBoxEmpty.new()
	UiTheme.set_stylebox("focus", "Button", empty)
	UiTheme.set_stylebox("focus", "ItemList", empty)
	UiTheme.set_stylebox("focus", "Label", empty)
	UiTheme.set_stylebox("focus", "LineEdit", empty)
	UiTheme.set_stylebox("scroll_focus", "VScrollBar", empty)
	
	var TileAtlas := AtlasTexture.new()
	var tile := StyleBoxTexture.new()
	TileAtlas.region = Rect2(0.0, 32.0, 16.0, 16.0)
	TileAtlas.atlas = ResourceLoader.load("res://Assets/" + ThemeList[ThemeId] + ".png")
	tile.texture = TileAtlas
	tile.set_texture_margin_all(3.0)
	UiTheme.set_stylebox("normal", "Button", tile)
	UiTheme.set_stylebox("hover", "Button", tile)
	UiTheme.set_stylebox("hovered", "ItemList", tile)
	UiTheme.set_stylebox("hovered_selected", "ItemList", tile)
	UiTheme.set_stylebox("hovered_selected_focus", "ItemList", tile)
	UiTheme.set_stylebox("panel", "ItemList", tile)
	UiTheme.set_stylebox("normal", "LineEdit", tile)
	UiTheme.set_stylebox("panel", "Panel", tile)
	UiTheme.set_stylebox("grabber", "VScrollBar", tile)
	UiTheme.set_stylebox("grabber_highlight", "VScrollBar", tile)
	UiTheme.set_stylebox("grabber_pressed", "VScrollBar", tile)
	
	var FlippedAtlas := AtlasTexture.new()
	var FLippedTile := StyleBoxTexture.new()
	FlippedAtlas.region = Rect2(0.0, 16.0, 16.0, 16.0)
	FlippedAtlas.atlas = ResourceLoader.load("res://Assets/" + ThemeList[ThemeId] + ".png")
	FLippedTile.texture = FlippedAtlas
	FLippedTile.set_texture_margin_all(3.0)
	UiTheme.set_stylebox("pressed", "Button", FLippedTile)
	UiTheme.set_stylebox("selected", "ItemList", FLippedTile)
	UiTheme.set_stylebox("selected_focus", "ItemList", FLippedTile)
	UiTheme.set_stylebox("scroll", "VScrollBar", FLippedTile)
	
