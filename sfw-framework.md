# sfw framework: working notes

Extends CLAUDE.md "Architecture: the sfw framework". Read from `Classes/sfw*.4dm`; never edit them.
The live code is `Classes/sfw_foundations.4dm`: `Form.sfw` is an `sfw_item`, which extends it.
`sfw.4dm` is an older copy that differs in places (used directly only by `cs.sfw.new()` in
`ga_stepDocuments` and `panel_planning`).

## Use these instead of writing your own

- Dialogs: `cs.sfw_dialog.me.alert(msg)`, `.info(msg)`, `.request(...)`, and `.confirm(msg; okLabel; cancelLabel)`,
  which returns a Boolean. Don't use ALERT / CONFIRM.
  `If (cs.sfw_dialog.me.confirm("Attach to the lot?"; "Attach"; "Skip"))`
- Timestamps (`sfw_stmp` fields): `cs.sfw_stmp.me.now()`, `.build($date; $time)`, `.getDate($stmp)`, `.getTime($stmp)`.
  `$e.expirationDate:=cs.sfw_stmp.me.build(Current date+365; ?00:00:00?)`
- Current user: `cs.sfw_userManager.me.info.UUID` / `.name`; profiles: `cs.sfw_userManager.me.authorizedProfiles`.
- Counters: `ds.sfw_Counter.getNextValue("ident")` (a DataClass function).
  `String(ds.sfw_Counter.getNextValue("Bin"); "0000000000")`
- Opening a record in its own window: `Form.sfw.openInANewWindow($entity; "visionIdent"; "entryIdent")`.
- Item action shown only when allowed: a 3rd argument `"activateIf:<4D expression>"` is evaluated as a formula.
  `$entry.setItemAction("Back-order"; "_ga_backorderBuyLine"; "activateIf:(Form.current_item#Null) && Form.current_item.canBackorder")`
- Custom "New ..." button: `setSpecificAddMode(ident; label; iconPath; "memberFunction")`. sfw creates the
  entity, then calls `ds[Dataclass].memberFunction()`. Returning True keeps the entity (then
  `loadAfterCreation` runs); False drops it.
- Validation rules: `"mandatory"` checks only Text (≠ "") and Date (≠ !00-00-00!). For numbers use
  `"notZero"`. For a link use widget `""` + `"UUIDNotNull"`.
  `$entry.setValidationRule("UUID_Customer"; ""; "UUIDNotNull"; "message:The customer must be defined")`
- Field history: `setAttributesToTrackInModificationEvent`, `setAttributeStmpToTrackInModificationEvent`
  (logs a stamp as a date or time, not a number) and `setLinkManyToOneToTrackInModificationEvent(name; fk; link)`.
  Use these instead of writing your own diff. They compare top-level values only (`clone.diff`), so a change
  inside an Object field isn't detailed: use `ga_events` for those (see `LotEntity.beforeSave/afterSave`).
- Custom history line: `cs.sfw_eventManager.me.createIfNotExist("ident"; "Label")`, then
  `.addEvent(Form.sfw.entry; "ident"; $uuid; $moreData)`.
- Attachments: `sfw_Document.processSaveFromFile($fileInfo; $blob)` / `getStoredBlob()`. Don't write files
  to DocumentData yourself. Folders are `sfw_DocumentFolder`, filtered by `moreData.allowedEntries` / `allowedProfiles`.

## Callback order (panel buttons)

- Save (`bItemSave`):
  1. project method `<Dataclass>_beforeSave(Form.subForm)` if it exists
  2. entity `beforeSave`
  3. `save()`, with the result in `Form.info`
  4. history event with the tracked diffs
  5. entity `afterSave` (check `Form.info.success`), still inside the transaction
  6. the transaction is validated, then `current_item.reload()`, a new `current_clone`, entity `itemReload`
- Create (Save in add mode):
  1. `<Dataclass>_beforeSave`
  2. if the project method `<Dataclass>_create` exists, it gets a copy of `current_item` as an object and
     must create and save the record itself; sfw then skips `beforeSaveCreation` and `save()`.
     Otherwise `beforeSaveCreation` then `save()`.
  3. event `createRecord` / `duplicateRecord`
  4. `afterCreation`
  5. the transaction is validated
- New: the entity is created (not saved), then `loadAfterCreation` runs, before the panel shows.
- Cancel: `<Dataclass>_beforeCancel`, then the transaction is cancelled, then `reload()` and `itemReload`.
- Delete: `beforeDelete`, then the entity leaves `lb_items`, then `drop()`.
- Duplicate: `duplicateRecord` on the copy.
- Entry-level hooks: `Form.sfw.callbackOnEntry("name")` calls a DataClass function `ds[Dataclass].name()`.

## Easy mistakes

- `beforeSave`, `afterSave` and the rest are sfw callbacks, not ORDA events. A `.save()` from a service, import
  or `_fix_*` method does NOT run them. Shared rules (stock sync, numbering) must be callable from both
  (e.g. `ga_stock.move` calls `syncFigures` itself).
- `checkIsInModification()` is also True in add and duplicate modes, and False when `Form.notEditable` is set.
  Use `Form.situation.mode` when you need to tell them apart.
- Don't call VALIDATE / CANCEL TRANSACTION in panel code. sfw owns the transaction of Modify / New. Records
  you save meanwhile are committed or rolled back with it.
- After a save, `Form.current_item` is reloaded. Values kept in variables or `Form.*` from before the save
  may be stale; recompute in `itemReload` / `updateOfPanelNeeded`.
- `Form.info` is overwritten by every Save. Don't store your own state there.
- Item actions: sfw first looks for a DataClass function with that name and runs it with `.call()`, so refer
  to `ds.Dataclass` inside it, not `This`. Otherwise it runs the project method of that name. An unknown
  name does nothing, with no error.
- `addEvent` does nothing if the entry has no `activateEvent`. `createIfNotExist` loads an existing type right
  away, but the very first time it creates the type through a worker, so an `addEvent` straight after can
  fail. Declare custom types at startup or in the entry definition, not just before the first `addEvent`.
- `setFilterByLinkedEntity(dc; fk; placeholder; link)`: the 4th argument must be an existing relation name,
  or Shift-click on the filter throws an error.
- `Form.sfw.lb_items` is an entity selection. To add a row: `Form.sfw.lb_items:=Form.sfw.lb_items.copy().add($e)`
  (it may be shareable). Deleted items are removed by sfw.
- Dynamic rendering (documents tab): the mirrored function receives every event of its object, so test
  `Form event code`. Objects that come from an inherited form (e.g. `hTabBar`) keep their own method.
