import gintro/[gtk4, gobject, gio]
import std/with, tables, hashes, parseutils
import envService

type
  AddControlData = tuple 
    nameEntry: Entry
    ageEntry: Entry
    list: StringList
  DeleteControlData = tuple
    selection: SingleSelection
    list: StringList

type
  Person = object
    id: int
    age: int
    name: string

type 
  FishWidget = ref object of Box
    idLabel: Label
    keyLabel: Label
    valueLabel: Label


var fishConfig = getFishEnv()
var redux: Table[int, EnvVar]
var idGb: int = 0

proc deletePerson(keyId: int) = 
  redux.del keyId 


proc createEnvVar(value: string, key: string): int = 
  fishConfig.addKV(value, key)
  result = fishConfig.high

  


proc createEmptyFishWidget(): FishWidget = 
  let
    FishWidget = newBox(FishWidget, Orientation.horizontal, 5)
    idLabel = newLabel()
    keyLabel = newLabel()
    valueLabel = newLabel()

  
  with FishWidget:
    idLabel = idLabel
    keyLabel = keyLabel
    valueLabel = valueLabel
    append idLabel
    append keyLabel
    append valueLabel
  
  result = FishWidget

proc fillFishWidgetFromRedux(FishWidget: FishWidget, id: int) =
  let fishConfigLine = redux[id]
  echo "fillFishWidgetFromRedux, id: ", id
  # echo person

  FishWidget.keyLabel.label = person.name
  FishWidget.valueLabel.label = $person.age



### Utils
func getNItems(self: StringList): int = 
  let lm = cast[ListModel](self)
  return lm.getNItems()

proc getString(self: ListItem): string = 
  let strobj = cast[StringObject](self.getItem())
  result = gtk4.getString(strobj)

### SignalFactory callbacks
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createEmptyFishWidget())
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  var num: int
  let
    FishWidget = listitem.getChild().FishWidget

  echo "bind_cb,listItem = ", listItem.getString()
  discard listItem.getString().parseInt(num)
  fillFishWidgetFromRedux(FishWidget, num)


proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  echo "unbind"

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild (nil)


### Controls callbacks
proc btnAddCb(btn: Button, controlData: AddControlData) =
  var num: int
  discard controlData.ageEntry.text.parseInt(num)
  if controlData.nameEntry.text != "" and controlData.ageEntry.text != "" and num != 0:
    let id = createEnvVar(controlData.nameEntry.text, num)
    controlData.list.append $id
  else:
    controlData.nameEntry.text = ""
    controlData.ageEntry.text = ""
  
proc btnAdd100Cb(btn: Button, controlData: AddControlData) =
  var num: int
  discard controlData.ageEntry.text.parseInt(num)

  for i in 0..100:
    let id = createPerson(controlData.nameEntry.text, num)
    controlData.list.append $id
    
  
proc btnRemoveCb(btn: Button, data: DeleteControlData) =
  data.list.remove data.selection.getSelected()
  deletePerson(data.selection.getSelected())
  
func btnRemoveAllCb(btn: Button, data: StringList) =
  data.splice(0, data.getNItems())

proc createTestData() =
  discard createPerson("ivan", 45) 
  discard createPerson("qwe", 42)
  discard createPerson("asd", 46)
  discard createPerson("pepa", 41)

proc activate(app: gtk4.Application) =
  createTestData()

  let
    # main
    window = newApplicationWindow(app)
    scrolled = newScrolledWindow()
    mainBox = newBox(Orientation.vertical, 0)

    # ListView
    sl = gtk4.newStringList("0", "1", "2", "3")
    ls = cast[ListModel](sl)
    ns = gtk4.newSingleSelection(ls)
    factory = gtk4.newSignalListItemFactory()
    lv = newListView(ns, factory)

    # Controls
    controlBox = newBox(Orientation.horizontal, 0)
    add = newButton("Add")
    add100 = newButton("Add100")
    remove = newButton("Remove")
    removeAll = newButton("Remove All")
    ageEntry = newEntry()
    nameEntry = newEntry()

  # Connect controls
  add.connect("clicked", btnAddCb, (ageEntry, nameEntry, sl))
  add100.connect("clicked", btnAdd100Cb, (ageEntry, nameEntry, sl))
  remove.connect("clicked", btnRemoveCb, (ns, sl))
  removeAll.connect("clicked", btnRemoveAllCb, sl)

  
  with controlBox:
    halign= Align.center
    setCssClasses("linked")
    append add
    append remove
    append removeAll
    append add100
    append ageEntry
    append nameEntry
  
  with scrolled:
    setChild lv
    vexpand = true

  with factory:
    connect("setup", setup_cb)
    connect("bind", bind_cb)
    connect("unbind", unbind_cb)
    connect("teardown", teardown_cb)

  with mainBox:
    append scrolled
    append controlBox

  with window:
    defaultSize = (500, 300)
    title = "Nim Simple Todo Example"
    setChild mainBox
    show

proc main =
  let app = newApplication("org.gtk.example")
  app.connect("activate", activate)
  discard run(app)

main()