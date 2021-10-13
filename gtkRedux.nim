import gintro/[gtk4, gobject, gio]
import std/with, tables, hashes, parseutils

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
  SasWidget = ref object of Box
    idLabel: Label
    nameLabel: Label
    ageLabel: Label

var redux: Table[int, Person]
var idGb: int = 0

proc deleteCustomSus(keyId: int) = 
  redux.del keyId 


proc createPerson(name: string, age: int): int = 
  result = idGb

  let person = Person(age: age, name: name, id: idGb)
  redux[idGb] = person
  echo "created sas with id: ", idGb, " and name: ", redux[idGb].name

  idGb.inc()
  


proc createEmptySasWidget(): SasWidget = 
  let
    sasWidget = newBox(SasWidget, Orientation.horizontal, 5)
    idLabel = newLabel()
    nameLabel = newLabel()
    ageLabel = newLabel()

  
  with sasWidget:
    idLabel = idLabel
    nameLabel = nameLabel
    ageLabel = ageLabel
    append idLabel
    append nameLabel
    append ageLabel
  
  result = sasWidget

proc fillSasWidgetFromRedux(sasWidget: SasWidget, id: int) =
  let person = redux[id]
  echo "fillSasWidgetFromRedux, id: ", id
  # echo person

  sasWidget.idLabel.label = $person.id
  sasWidget.nameLabel.label = person.name
  sasWidget.ageLabel.label = $person.age



### Utils
func getNItems(self: StringList): int = 
  let lm = cast[ListModel](self)
  return lm.getNItems()

proc getString(self: ListItem): string = 
  let strobj = cast[StringObject](self.getItem())
  result = gtk4.getString(strobj)

### SignalFactory callbacks
proc setup_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild(createEmptySasWidget())
  
proc bind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  var num: int
  let
    sasWidget = listitem.getChild().SasWidget

  echo "bind_cb,listItem = ", listItem.getString()
  discard listItem.getString().parseInt(num)
  fillSasWidgetFromRedux(sasWidget, num)


proc unbind_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  echo "unbind"

proc teardown_cb(factory: gtk4.SignalListItemFactory, listitem: gtk4.ListItem) =
  listitem.setChild (nil)


### Controls callbacks
proc btnAddCb(btn: Button, controlData: AddControlData) =
  var num: int
  discard controlData.ageEntry.text.parseInt(num)
  if controlData.nameEntry.text != "" and controlData.ageEntry.text != "" and num != 0:
    let id = createPerson(controlData.nameEntry.text, num)
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
    
  
func btnRemoveCb(btn: Button, data: DeleteControlData) =
  data.list.remove data.selection.getSelected()
  
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