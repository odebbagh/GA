# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

GoldenAltos ERP: a 4D (v20+, project mode) application for a semiconductor test / screening lab
(receiving customer lots, planning travellers, production punch in/out, holds and NCMN, serialization,
inventory, buying, invoicing). It replaces a legacy 4D app, `erp2020v18`, which sits next to this repo
(`../erp2020v18/Project/Sources`, 4D v18 classic code) and is used as the reference for business rules.

- Project file: `Project/golden_altos_erp.4DProject`; code in `Project/Sources/`.
- Structure: `Project/Sources/catalog.4DCatalog` (XML). The `catalog.4DCatalog` at the repo root is not the live one.
- Data (`Project/Data`), `DerivedData`, `DocumentData`, logs are git-ignored.
- `Project/imports/`: JSON exports from the legacy app used by the `_import_*` methods, and the text
  reports written by `_diag_*` / `_fix_*` methods.

## Building, running, checking

There is no CLI build, linter or test runner. Everything happens in the 4D IDE:
- Compile from 4D (Design > Compiler). A change to `catalog.4DCatalog` needs 4D to be restarted.
- `_demo_check` is the self-check method (runs fixtures, `_fix_sequences`, and prints pass/fail).
- Behaviour is verified by running methods and the screens; the manual test / demo plan lives outside the repo.
- One-time data methods follow a convention: `_diag_*` are read-only and write a report to
  `Project/imports/*.txt`; `_fix_*` repair data and ask first ("Report only" / "Apply") where the change is large.
- Legacy analysis is done with read-only `__ga_*` audit methods added to the legacy project
  (they write `*_audit.txt/json` to the Desktop). Never change legacy business code.
- After every change, end with: the files modified, where to test the
  change in the IDE, and anything elsewhere that could be affected
  (other panels or services that call the changed code).

## Hard rules

- **Never modify anything named `sfw_*`** (classes, methods, forms: the proprietary sfw framework).
  Reading it and calling its public functions is fine. Fix bugs in the app code that calls it.
- The QA module was not written by the current developer: do not change `panel_audit`,
  `panel_managementReview`, `panel_continuousImprovement`, `panel_qcar`, `sub_panel_qcar`,
  `panel_specification`, `panel_staff`, `panel_supplier`, `panel_rma`, `panel_AML`,
  `panel_certification` (and their forms) without asking.
- UUID attributes are Text: never wrap them in `String()`. An empty link is `"0"*32`; test emptiness with
  `cs.sfw_string.me.isAnEmptyUUID()`. Foreign-key fields must not be `autogenerate` in the catalog
  (that fills them with random values pointing to nothing).
- Before editing, copy the original files to `bak/before_<topic>/` (the repo's convention).

## Architecture: the sfw framework

- **Entries** (the left-menu screens) are declared in `Classes/goldenAltos_definition.4dm` and in
  `entryDefinition()` functions of DataClass classes (e.g. `Classes/Inventory.4dm`, `Job.4dm`,
  `JobInvoice.4dm`): dataclass, panel form, pages, list columns, filters, views, item actions
  (`setItemAction("Label"; "methodName")`), validation rules, `enableTransaction()`,
  `activateEvent` (history) and `activateDocument` (Documents tab).
- **Panels**: each entry's detail is a form `Forms/panel_X` plus a singleton class `Classes/panel_X`.
  The form method is `cs.panel_X.me.formMethod()`, which routes: `Form.sfw.panelFormMethod()`, then
  `updateOfPanelNeeded()` (record changed), `recalculationOfPanelPageNeeded()` (page data),
  `redrawAndSetVisibleInPanelNeeded()` (`redrawAndSetVisible()`: visibility, enabling, layout).
  Object methods are one-liners calling class functions. `Form.current_item` is the entity,
  `Form.sfw` the framework instance.
- Objects whose name contains `entryField` are made enterable by sfw in Modify; rename an object to
  make it read-only. `Form.sfw.drawButtonPup(name; title; icon; isError)` draws pop-up buttons (pass
  `" "` instead of `""` to clear a title).
- Entities get framework callbacks: `loadAfterCreation`, `afterCreation`, `beforeSaveCreation`,
  `beforeSave`, `afterSave` (local functions on the `*Entity` classes). Modify runs inside a
  transaction: Cancel rolls back everything saved meanwhile.
- `activateDocument()` switches the panel to **dynamic rendering**: every form object method is
  replaced by `sfw_dynamicForm_script`, which calls `cs.panel_X.me[objectName]()` and silently does
  nothing if there is no such function. Panels with a Documents tab (`panel_planning`,
  `panel_inventory`, ...) therefore mirror each object method as a class function of the same name
  (section "Dynamic-rendering mirrors" at the end of the class). Change both when editing one.
- Forms are JSON (`form.4DForm`); the order of objects is the z-order. Edit them as text, keeping order
  and line endings, rather than re-serializing.
- Framework reference (built-ins to use, callback order, common mistakes): see @sfw-framework.md .
  Read it before writing panel, entry or entity-callback code.

## Architecture: domain

- **Lot** (a customer lot / traveller) belongs to a **Job**; its **LotStep** records are the
  traveller steps. Planning (`panel_planning`) plans steps; Production Punch In / Punch OUT
  (`panel_punch_in`, `panel_punch_out`, LotStep dataclass) run them. `displayNumber` (41, sublot 41-1)
  is what users read; `number` is the unique internal counter (`LotSplitService.freeLotNumber`,
  `_fix_sequences` keep counters ahead of imported numbers).
- Shared rules live in singleton service classes `ga_*` / `*Service`: `ga_serialization` (SN tables,
  SNA/SNF step properties), `LotSplitService` / `LotMergeService` (split by qty or SN; merge only at the
  same step), `ga_events` (lot history added to sfw events), `ga_stock` (the only way inventory stock
  moves: a recorded `InventoryPull` line and `availableQty` saved together; `qtyInStock` and value are
  kept in sync), `ga_inventoryPulls`, `ga_datePicker`, `ga_operator`.
- Holds: `Lot.lotHold` holds on/off events; NCMN / ISSNF forms are stored per hold in `Lot.NCMN` /
  `Lot.ISSNF` (`LotHoldForm_*` methods).
- Many fields are `sfw_stmp` numeric timestamps, not Dates (e.g. `Inventory.expirationDate`; date views
  like `expirationDate_d` exist on the entity). Comparing a stamp with a Date throws error 15.

## Printing

- **dfd templates** (travellers): `dfd_Template` / `dfd_Line` records in the data file, built and
  patched by `Planning_seed*` methods; data objects built by `Planning_fillLotTravData`,
  `Planning_lotTrav*`. Tags are `##this.attr##`; an object's `visibility` can be a tag.
- **4D Write Pro models**: `sfw_DocumentModel` records (Document Management > Models), seeded from
  `Resources/4DWriteProPrintTemplates/*.4wp` by `_ga_build*` / `_ga_install*` methods. Values are
  `{{token}}` placeholders replaced by `_wpFill`. The GAF forms (GAF-1014 NCMN, GAF-1514 ISSNF) are
  drawn with positioned boxes (`_wpGaf*` helpers) from the original PDF coordinates.
- Barcodes: `_ga_generateBarCodeBase64` renders JsBarcode in an offscreen web area
  (`Resources/barCode_encoder.html`).

## 4D gotchas met in this code

- `Choose()` evaluates both branches; `|` and `&` do not short-circuit (use `||` / `&&`).
- `Time + number` must be wrapped in `Time()`.
- Code files mix tokenized (`New object:C1471`) and plain command names; both compile. Most files use
  CRLF line endings: keep them.
- In error dialogs, line numbers do not count the hidden `//%attributes` first line of a method file.
- Method names have a hard 31-character limit.
