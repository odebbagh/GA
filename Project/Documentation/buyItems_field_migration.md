# [BUY_ITEMS] → BuyingOrderLine — migration decisions

Consolidated. Supersedes the earlier working draft.

- **Source**: legacy `[BUY_ITEMS:27]` — 71 fields, 7,591 records
- **Target**: `BuyingOrderLine` — 39 columns + `moreData`
- **Basis**: distinct-value counts + 2,675 code references across the legacy source

**Guiding rule (decided):** prefer a **table link** over a copied value, and a **framework
feature** over a custom field. Any field that represents or triggers a **workflow that does
not exist in GA yet** has its value set aside rather than exposed as an editable field.

Buckets: **REUSE** (column or relation) · **LEGACY** (`moreData.legacy.*`, read-only) ·
**PENDING** (`moreData.pendingWorkflow.*`) · **NOT CREATED**

---

## ⚠ Blocking architectural decision — Supplier vs Customer

GA currently has **two competing vendor models**, and `BuyingOrder` carries relations to both:

| | `Supplier` | `Customer` with `vendor = true` |
|---|---|---|
| Origin | faithful port of legacy `[Suppliers:18]` | a boolean on the customer table |
| QA apparatus | `approvedByQA`, `disqualified`, `auditRequired`, `stmpLastAudit`, `stmpNextAudit`, `critical`, `qaComment`, `RatingData` | none |
| Entry | "AVL", qualityAssurance vision | "Vendors", buying vision (`panel_vendor`) |
| Used by | **`AML.UUID_Supplier`** | **`_import_buyOrders` sets `UUID_Customer`** |

**Decision: keep `Supplier`, retire the vendor-as-Customer model.**

This matters for the field migration: once buy-order lines link to `AML` for part numbers, a
line's **part** resolves its vendor through `Supplier` while its **order** resolves the vendor
through `Customer` — two records for one company, unlinked. The legacy rule "only parts
approved for *this* vendor" cannot work across that split.

### Sequence (so nothing breaks mid-flight)

1. Add relation **`Contact → Supplier`** on the existing unused **`Contact.UUID_Company`**
   (field 13, no relation defined — it was clearly added to decouple contacts from Customer).
   Contacts then attach to either side; `UUID_Customer` stays for customer contacts.
2. Switch `_import_buyOrders` to populate **`UUID_Supplier`** instead of `UUID_Customer`. ← most urgent, every import lands on the wrong relation until then
3. Repoint the `boItems` listbox from `buyingOrder.customer.name` to `buyingOrder.supplier.name`.
4. Migrate existing vendor-`Customer` records and their contacts to `Supplier`.
5. Only then retire `Customer.vendor` and the `vendor` entry.

Steps 2–3 are code and can be done immediately. Steps 1 and 4 need the structure editor.

**Check before collapsing:** legacy had an `Internal` flag on `[Suppliers]` (inherited by
`[BUY_ORDERS]Internal`) for inter-company entities — companies that are both customer and
vendor. If that is real in your data you need one company with two roles, not a deletion.

**Bug spotted:** the `Contact → Customer` relation is named **`auditStatus`** in the catalog —
almost certainly a copy-paste error. `eContact.auditStatus` returning a Customer is confusing.

---

## 1. REUSE

### 1a. Existing columns — already correct

`PO_NUM`→`boNumber` · `QTY`→`qty`+`qtyOrdered` · `Unit_Price`→`unitPrice` ·
`Date_required`→`requiredDate` · `Date_in`→`dateIn` · `Taxable`→`taxable` ·
`Line_total`→`lineTotal` · `Description`→`description` · `TAX`→`tax` ·
`Order_Date`→`orderDate` · `Assetlist_num`→`assetListNumber` ·
`Int_jobnum`→`jobNumber`+`UUID_Job` · `Sup_ps_num`→`supPsNumber` ·
`Inventory`→`inventory` · `Glac`→`glAccount` · `Qtyin`→`qtyReceived`

### 1b. Existing columns — newly wired up (done in code)

| Legacy | Target | Note |
|---|---|---|
| `Item` | `number` | column existed, nothing wrote it |
| `Units` | `UUID_Unit` + `units` | the `unit` relation existed and was never set |
| `ConfirmationDate` | `confirmationDate` | column existed, value went only to `moreData` |
| `Comments` | **notes feature** (`sfw_Comment`) | one legacy field can hold several notes, split on CR |

### 1c. New relations — structure change required

| Legacy | New FK | Relation | Target | Note |
|---|---|---|---|---|
| `Recd_by` | `UUID_Staff` | `receiver` | `Staff` | **Read-only on Buy Items**; selection happens in the Receiving module. Both forms bind the same table. Name matches the existing `Inventory → Staff` relation. |
| `Division` | `UUID_Division` | `division` | `Division` | Matches `Specification`, `Equipment`, `Supplier`, `AML`. Only one record today (GAC). |
| `Part_num` **+** `Vendor_partnum` | `UUID_AML` | `aml` | `AML` | **One relation replaces both fields.** |

**Why AML covers both:** GA's `AML` is a complete port of legacy `[AVL_Supplies:28]` —
`ourPartNum`, `vendorPartnum`, `UUID_Supplier`, `UUID_Division`, `service`, `makeInactive`,
`procurementUnits`, `inventoryUnits`, `transFactor*`, plus new `isApproved`/`approvedBy`/
`stmpApproval`. It already relates to `PartData`, so a separate `UUID_PartData` on the line
would be redundant.

The legacy picker (`BI_EntryF/Field17`) filtered AVL on `Supplier = the order's vendor` +
`Service = False` + `MakeInactive = False`, and pulled part / vendor part / description /
units / comments from one row. In GA that becomes a query on `UUID_Supplier` + `service=false`
+ `makeInactive=false`, and should probably add `isApproved=true`.

### 1d. New plain columns — structure change required

| Legacy | Column | Type | Why |
|---|---|---|---|
| `Freight` | `freight` | real | Never written by code — typed by the buyer. Appears everywhere as `lineTotal + freight − discount`: a per-line shipping cost that adds to what is owed but is **not** part of the goods' value, which is why it sits outside `lineTotal`. Needed at order time regardless of AP. |
| `Consumable` | `consumable` | boolean | Completes the GL classification trio with the existing `inventory`. |
| `Asset` | `asset` | boolean | Same trio. GL-derived, but needed at order/receipt time, long before AP. |
| `UnitPriceWithSalesTax` | `unitPriceWithTax` | real | Real money, and the **entered** field in VAT mode. |

**The classification trio** is derived, never user-set — `SetBuyingFieldsBasedonGLacc` reads the
GL account type: expense (`$ACode=16`) → `consumable`; Fixed Asset / @Asset → `asset`;
otherwise → `inventory`. Mutually exclusive, and it decides what happens on receipt (stock /
expense / capitalise) and whether a job number is required.

### 1e. `unitPriceWithTax` — formula to implement

Two directions, selected by the order's VAT mode. Implement once as an entity function, not
scattered across form object methods as it is in legacy.

**Normal** — `unitPrice` entered, tax-inclusive derived:
```
unitPriceWithTax = taxable ? unitPrice × (1 + salesTaxRate) : unitPrice
```

**VAT mode** (`[BUY_ORDERS]VATMode = True`) — inverts; `unitPriceWithTax` is entered,
`unitPrice` back-computed, and `taxable` is **forced true and locked**:
```
unitPrice = (unitPriceWithTax / (100 + salesTaxRate × 100)) × 100
```

Both recalculate on any change to `unitPrice`, `unitPriceWithTax` or `taxable`, and each
triggers the line-total recalc.

---

## 2. LEGACY → `moreData.legacy.*` (read-only)

Accounting and dead fields share one bag, per decision.

**Accounting / AP (14)** — module not built yet:
`Invoice_num` · `Invoice_date` · `BillRecognitionDate` · `Pay_amt` · `Amt_outstanding` ·
`OK_to_Pay` · `Multi_chks` · `Pay_Before` · `Last_pay_date` · `Disputed_inv` · `Ddays` ·
`Paid_date` · `Check_num` · `T_paid`

**Identity / superseded (7)**:
`Seq_Number` (also the `legacySeqNum` column) · `UniqueID` · `DateTimeStamp` ·
`CreationDateTimeStamp` · `Vendor` · `RelationalString` · `DocumentsinDocServer`

Notes for whoever builds the AP module:
- **`Amt_outstanding` should not be stored** — it is `lineTotal − discount + freight − amountPaid`, recomputed on every legacy save. Derive it.
- **`BillRecognitionDate` carries the heaviest rule set in the legacy app**: rejected in a closed period; warns if before order date; rejected if its period is later than the payment period (checked against `[Check_Register]` / `[PartialPays]`); unlocking needs CFO control or the `BypassCFOControlOfBill-RecognitionDate` rule; the trigger defaults it from `Invoice_date` or the earliest partial-pay invoice date.
- **`Multi_chks`** switches `T_paid` to `Sum([PartialPays]Amt)` and changes how `BillRecognitionDate` is derived.

---

## 3. PENDING → `moreData.pendingWorkflow.*`

| Field | Workflow |
|---|---|
| `Return_To_Vendor` | **Vendor returns** — does not exist in GA |

**GA's `RMA` table does not satisfy this.** It is the *customer* side: its only relation is
`qcar` → `Qcar`, its listbox shows `qcar.customer.name`, and its fields are `customerPo`,
`customerSvc`, `contact`, `phone`, `reasonForReturn`, `materialDisposition`, `travelerNumber`.
Legacy `Return_To_Vendor` is the opposite direction — goods going back to a *supplier*.

Legacy behaviour, for whoever builds it: `ReturnPurchasedInventoryItem` finds the buy item by
`Seq_Number`, **blocks if the accounting period is closed**, sets the flag, stamps `RMA_Date`,
**zeroes `Qtyin` / `TAX` / `Line_total`** (keeping order qty), appends a note to the
description, and feeds `VendorDebitMemo`. It is also a factor in the line-total formula:
`(QTY × Unit_Price) × Not(Return_To_Vendor) − Credit`.

**Design warning:** the legacy workflow *mutates the line*. If the new one does the same, line
totals must be **derived**, not stored — otherwise a return silently rewrites history, which is
exactly why the legacy formula needs that `Not(...)` factor.

**Data oddity:** `Return_To_Vendor` has 2 distinct values (some lines are flagged) but
`RMA_Date` has only 1 (empty). Likely those returns came through `ReturnManufacturedItem`,
which sets the flag but not the date. The returned lines have no return date recorded.

---

## 4. NOT CREATED

**The 16 unused legacy fields** (no data):
`Accepted_by` `Discount` `Disc_yes` `RMA_num` `Reason` `Ppays` `M1099` `Discount_rate`
`Internal` `Requisition` `LotStep_Number` `CreationID` `Credit` `CreditDTStamp`
`AlternateCheckName` `RMA_Date`

- `Discount_rate`, `Internal`, `M1099` **are** written by legacy code — empty because unused, so dropping them is a business decision, not dead-code removal.
- `Credit` and `Discount` appear in **live formulas** (`lineTotal` subtracts `Credit`; `amountOutstanding` subtracts `Discount`). They evaluate to 0 today — safe to drop provided the new calculation does not reintroduce the terms.

**Dropped by decision:**

| Field | Reason |
|---|---|
| `Currency` | Always `$` in the legacy data; client confirmed |
| `Vendor_partnum` | Reachable through `AML` |
| `Vendor` | Reachable through `buyingOrder.supplier` |
| `RelationalString` | Superseded by real UUID relations |
| `DocumentsinDocServer` | Superseded by the framework Documents feature |
| `Invalid` | Line-voiding workflow not planned |
| `Exception` | Legacy auto-correction history, not a workflow |
| `totalPaid` *(new side)* | Duplicate of `amountPaid` — delete the column |

---

## 5. Still open

| # | Question |
|---|---|
| O1 | **`Virtual_inventory`** — what is it for? 2 code references only. Not yet investigated. |
| O2 | **`CheckFlag`** — what is it for? Auto-cleared whenever `Unit_Price` changes. Does it map to the existing unused `verificationRequired` column? Not yet investigated. |
| O3 | **`OK_to_Pay`** — is it a free checkbox or driven by something? Not yet investigated. |
| O4 | `Paid_date`, `Check_num`, `T_paid` are **live populated columns** (`paidDate`, `checkNumber`, `amountPaid`) but classified as accounting/legacy. Move them into the bag (deleting working columns) or leave as columns? **Recommendation: leave them.** |
| O5 | `Amt_outstanding` — import the historical value as a snapshot, or omit and derive? |
| O6 | Does any company exist as **both** customer and vendor? Decides whether Customer/Supplier can be collapsed. |

---

## 6. Already applied in code

In `_import_buyOrders`:
- `confirmationDate` column populated (was `moreData` only)
- `UUID` set on every line (`Generate UUID`)
- `Item` → `number`
- `Units` → `UUID_Unit` resolved alongside the canonical name
- duplicate `moreData` copies of `inventory` / `tax` / `units` removed
- `vendor`, `relationalString`, `virtualInventory`, `documentsInDocServer` no longer carried
- `moreData` restructured into `legacy` + `pendingColumn` groups
- line `comments` now also imported into the **notes feature** (`sfw_Comment`), with the
  re-run purge extended to drop line-level comments

On the `boItems` entry:
- framework **Documents** page added (`activateDocument("showCountInTab")`)
- notes feature (`activateComment`) confirmed already present
- pages 3–5 removed; six form object methods mirrored as class functions so the panel keeps
  working under dynamic-source rendering

## 7. Remaining structure work

**Add:** `UUID_Staff` (`receiver`) · `UUID_Division` (`division`) · `UUID_AML` (`aml`) ·
`freight` real · `consumable` boolean · `asset` boolean · `unitPriceWithTax` real

**Add elsewhere:** `Contact → Supplier` relation on `Contact.UUID_Company`

**Delete:** `totalPaid`

Then `_import_buyOrders` gets its second pass: three relation lookups, four column
assignments, and the values move out of `moreData.pendingColumn`.

---

# 8. Next steps — who does what

Ordered. Items marked **[blocked]** wait on something above them.

## Can be done in code now (Claude)

| # | Task | Why now |
|---|---|---|
| C1 | Switch `_import_buyOrders` to populate **`UUID_Supplier`** instead of `UUID_Customer`, and repoint the `boItems` listbox to `buyingOrder.supplier.name` | Every import currently lands on the wrong relation. Self-contained, no structure change. |
| C2 | Investigate **O1–O3** (`Virtual_inventory`, `CheckFlag`, `OK_to_Pay`) and report | Needed before those three can be categorised. Read-only analysis. |
| C3 | Implement the **`unitPriceWithTax`** two-direction formula as an entity function on `BuyingOrderLineEntity` | The rule is known and documented in §1e; it does not depend on the new column existing. |
| C4 | Add the **read-only accounting tab** to the `boItems` panel, bound to `moreData.legacy.*` | Gives the AP values somewhere visible instead of being invisible in a blob. Optional. |

## Needs the 4D structure editor (you)

| # | Task |
|---|---|
| U1 | Add to `BuyingOrderLine`: **`UUID_Staff`** (relation `receiver` → `Staff`), **`UUID_Division`** (relation `division` → `Division`), **`UUID_AML`** (relation `aml` → `AML`) |
| U2 | Add to `BuyingOrderLine`: **`freight`** real, **`consumable`** boolean, **`asset`** boolean, **`unitPriceWithTax`** real |
| U3 | **Delete** `BuyingOrderLine.totalPaid` (duplicate of `amountPaid`) |
| U4 | Add relation **`Contact → Supplier`** on the existing `Contact.UUID_Company` |
| U5 | *(optional)* rename the `Contact → Customer` relation — currently misnamed `auditStatus` |

## Decisions only you can make

| # | Question | Recommendation |
|---|---|---|
| O4 | `Paid_date` / `Check_num` / `T_paid` are live columns but classified accounting — move to the bag or leave? | **Leave as columns** |
| O5 | `Amt_outstanding` — import the historical value or omit and derive? | **Omit**, derive on display |
| O6 | Is any company both customer **and** vendor? | Decides whether Customer/Supplier can collapse at all |

## Then, in order

| # | Task | Owner |
|---|---|---|
| 1 | **[blocked on U1–U3]** Second pass on `_import_buyOrders`: three relation lookups, four column assignments, values move out of `moreData.pendingColumn` | Claude |
| 2 | **[blocked on 1]** Re-run `_import_buyOrders` — it truncates and rebuilds, so it is a clean swap | You |
| 3 | **[blocked on U4]** Migrate vendor-`Customer` records and their contacts to `Supplier` | You |
| 4 | **[blocked on 3]** Retire `Customer.vendor` and the `vendor` entry | You |

## Unrelated but outstanding

- **`_import_users` has never been run.** It is written, verified and CRLF-fixed in GA, but no import has happened. `Staff` records are a prerequisite for the `UUID_Staff` (`receiver`) relation to resolve to anything, so this should happen **before** step 1 above.
- Order: `_import_userProfiles` first, then `_import_users`.
- `_export_users` on the legacy side has also never been run in anger — the CRLF fix means it should now appear in the Explorer after a project reload.

---

### C1 — DONE (this session)

`_import_buyOrders` now links buy orders to **`Supplier`**, not `Customer`:

- lookup map rebuilt from `ds.Supplier.all()` instead of `ds.Customer.query("vendor = true")`
- `$bo.UUID_Supplier` assigned instead of `$bo.UUID_Customer`
- `$existingCustomers` / `$customerUUID` / `$customer` renamed to their Supplier equivalents
- `boItems` **and** `BuyOrders` entries: listbox column and searchbox repointed from
  `buyingOrder.customer.name` to `buyingOrder.supplier.name` (4 places)

**Bonus finding:** the contact lookup at the end of the buy-order block already queried
`Contact.UUID_Company = <vendor UUID>`. It was being handed a *Customer* UUID; it now receives
a *Supplier* UUID — which is what `UUID_Company` was added for. So U4 (the `Contact → Supplier`
relation) only formalises what the data already does.

Still to do on the Supplier track: **U4** (relation), then migrate existing vendor-`Customer`
records to `Supplier`, then retire `Customer.vendor`.

---

### Structure verification (this session)

Checked `catalog.4DCatalog` against U1–U4.

**Landed:** `UUID_Staff` (id 40) · `UUID_Division` (id 41) · `UUID_AML` (id 42) ·
`freight` (43) · `consumable` (44) · `asset` (45) · `unitPriceWithTax` (46).
`totalPaid` is gone. U2 and U3 complete.

**Three gaps:**

| | Expected | Found |
|---|---|---|
| `UUID_AML` | relation `aml` → `AML` | **field + index only, no relation defined.** `AML`'s only relations are its own outbound `supplier` / `partData` / `division`. |
| `UUID_Staff` | relation named **`receiver`** (matching `Inventory → Staff`, relation `FC14A354…`) | named **`staff`** (`name_1toN="buyingOrderLines"`) |
| U4 `Contact → Supplier` | on `Contact.UUID_Company` (`1CA2A874…`) | **not present.** That field UUID appears exactly once in the catalog — its own declaration. The `supplier` relation on a `UUID_Company` at line 3662 belongs to **`Audit`**, not `Contact`. |

`UUID_AML` must be relation-backed before the second import pass — the AML lookup has
nothing to traverse otherwise.

---

### C2 — O1–O3 answered (from data, not code)

The legacy method source is **not on this machine**: `SetBuyingFieldsBasedonGLacc`,
`ReturnPurchasedInventoryItem` and `BI_EntryF` return zero hits anywhere under
`Desktop/Projects`. The 2,675-reference analysis cannot be reproduced. Answered instead by
cross-tabulating all **11,860** lines in `buyOrders_export.json`.

**O1 — `Virtual_inventory`: a fourth classification state. Keep it.**

| | `inventory=false` | `inventory=true` |
|---|---|---|
| `virtualInventory=false` | 10,496 | 710 |
| `virtualInventory=true` | **654** | **0** |

Perfectly disjoint from `inventory`, and 652 of its 654 rows carry **no** GL classification
at all. It is not noise and not a duplicate — it is a stocked-but-not-physical item, a
sibling of `inventory`. The §6 decision to stop carrying it drops a real distinction on 654
records. **Recommend reversing that** and giving it a `virtualInventory` boolean.

**O2 — `CheckFlag`: a verification flag on virtual-inventory lines. Maps to `verificationRequired`.**

Contained almost exactly inside `virtualInventory`: 647 of 654 virtual rows are flagged, and
`checkFlag` is **never** true on a non-virtual row (0 of 11,206). Combined with the known
"auto-cleared whenever `Unit_Price` changes" behaviour, this is a price-verification flag.
The existing unused `verificationRequired` column (type 1, id 27) is the right home.

**O3 — `OK_to_Pay`: derived from invoice entry, not a free checkbox.**

| | count |
|---|---|
| `okToPay=1`, has invoice number | 9,271 |
| `okToPay=0`, no invoice number | 2,570 |
| `okToPay=0`, **has** invoice number | 19 |

Near-total correlation with invoice presence; the 19 exceptions read as manual holds. It is
an AP gate, which confirms its placement in `moreData.legacy.*`. Whoever builds AP should
derive the default and keep the override.

---

### Two corrections to this document

**1. The classification trio is NOT mutually exclusive.** §1d says it is. The data:

| consumable | asset | inventory | count |
|---|---|---|---|
| 1 | 0 | 0 | 10,353 |
| 0 | 1 | 1 | **710** |
| 0 | 1 | 0 | 126 |
| 0 | 0 | 0 | 671 |

Every `inventory=true` row is **also** `asset=true` — there is no inventory-only row. So the
GL rule is not a three-way switch; inventory implies asset. Any receipt logic written on the
"mutually exclusive" assumption will be wrong for all 710 inventory lines.

**2. `lineTotal` is tax-inclusive.** §3 quotes the legacy formula as
`(QTY × Unit_Price) × Not(Return_To_Vendor) − Credit`, with no tax term. Against 823 taxable
lines:

- `lineTotal = qty × unitPrice × (1 + salesTaxRate)` → **822** match; `= qty × unitPrice` → **0**
- `tax = qty × unitPrice × salesTaxRate` → 822 match
- non-taxable lines carry `unitPriceWithTax = unitPrice` (9,175 of 9,261), not 0

Also: **`BuyingOrder.salesTaxRate` is a fraction** (0.0925 = 9.25%), unlike `SalesTax.rate`,
which is a percentage and is divided by 100 at every use site. §1e's two formulas are both
consistent with the fraction scale, so they are correct as written — but the distinction is
easy to get wrong and now has a comment in the code.

---

### C3 — DONE (this session)

Four functions added to `BuyingOrderLineEntity`, with the derivation evidence in comments:

- `get salesTaxRate()` — from the order, fraction scale
- `get vatMode()` — reads `buyingOrder.moreData.vatMode`, defaults **False**
- `recalcPrices()` — the two-direction rule, then calls the line total
- `recalcLineTotal()` — `tax` and `lineTotal` from the net `unitPrice`

**`BuyingOrder.VATMode` does not exist in GA** — no column, and the legacy export never
carried it, so nothing to import either. Every order therefore behaves in Normal mode today.
The VAT branch is written and correct; `get vatMode()` is the single line to change when a
real column is added. **Decision needed: add `BuyingOrder.VATMode`, or is VAT mode dead?**

Also repointed on `panel_boItem`, now that U2 landed:
`Field_UnitPriceWithSalesTax` `moreData.unitPriceWithSalesTax` (text) → `unitPriceWithTax`
(number) · `Field_Freight` `moreData.freight` (text) → `freight` (number), both with the
`###,##0.00` format the other money fields use. Both read empty until the second import pass.

**Not wired to the panel, deliberately.** Every price field on `panel_boItem` is
`enterable: false`, and there is no `taxable` control on the form at all — so there is no
edit event for `recalcPrices()` to hang off. Making them enterable and adding the checkbox
changes how the panel behaves and is a separate call.

**Spotted in passing:** `field_asset_list_number` binds
`current_item.moreInfo.legacy.assetListNumber` — `moreInfo` is not an attribute on this table
(`moreData` is), and it duplicates `entryField_Assetlist_num`, which binds the real column.
Dead field. Left alone.

---

### Second import pass — DONE (this session)

U1–U3 verified in the catalog: `receiver` → `Staff`, `division` → `Division`,
`aml` → `AML.UUID` all present and correctly named. `_import_buyOrders` updated.

**Four columns assigned directly:** `freight` · `consumable` · `asset` ·
`unitPriceWithTax` (from `unitPriceWithSalesTax`).

**Three relation lookups**, each built as a map before the record loop and each reporting
its misses rather than failing:

| Relation | Key | Note |
|---|---|---|
| `receiver` | `Staff.code` | `Recd_by` is a **six-digit employee code** (`001492`), not a name — 22 distinct values. The existing `$existingStaff` map is keyed on first+last name and cannot serve it, so a second map was added. `_newStaffFor` writes `employeeCode` verbatim into `Staff.code`, which is the join. |
| `division` | folded `Division.name` | Every legacy line reads `GAC`. Built generically, but unlike `_newStaffFor` it does **not** create a missing division — an unexpected value is reported. |
| `aml` | `UUID_Supplier` + folded `ourPartNum` | Scoped to the order's supplier, matching the legacy picker's `Supplier = the order's vendor` filter, plus `service=false` + `makeInactive=false`. |

**Two judgement calls on the AML lookup:**

- **No bare part-number fallback.** The same part number can exist for several vendors;
  matching across them is exactly the cross-vendor bug the Supplier decision was taken to
  avoid. An order with no supplier link therefore produces no AML link, by design.
- **`isApproved` is not filtered.** §1c suggests adding it. Historical lines were placed
  before that flag existed, so requiring it would drop legitimate links. It belongs on the
  *picker* for new lines, not on the import.

Only **1,371 of 11,860** lines carry a part number at all, so AML coverage is ~12% at best.

**`moreData` restructured:** `pendingColumn` is gone — everything in it either became a
column or was dropped. `returnToVendor` moved to a new **`moreData.pendingWorkflow`**, which
is what §3 always specified (it was sitting in `pendingColumn` alongside fields that were
getting real columns, so the second pass would have silently dropped it). `currency` dropped
per §4.

**One deviation from §4:** `partNumber` and `vendorPartNumber` are kept in
`moreData.legacy.*` rather than dropped. §4 drops them as "reachable through AML" — but that
only holds for lines the AML lookup actually matches, and the match rate is unknown until the
import runs. Cheap insurance; delete them once the report shows the real coverage.

The report now prints linked / no-value / unmatched counts for all three relations, and lists
the unmatched `Recd_by` codes, division values and part numbers.

**Prerequisite unchanged:** `_import_userProfiles` then `_import_users` must have run, or
every line lands in "Recd_by not matched" — the report names that case explicitly.

---

### Still open after this session

| # | Item | Needs |
|---|---|---|
| U4 | `Contact → Supplier` on `Contact.UUID_Company` — **still not added** (the `supplier` relation on a `UUID_Company` in the catalog belongs to `Audit`) | you, structure editor |
| U5 | rename the `Contact → Customer` relation, currently `auditStatus` | you, optional |
| — | **`virtualInventory` column** — 654 real rows, disjoint from `inventory`; currently dropped on every import re-run | you, structure editor (decision first) |
| — | **`CheckFlag` → `verificationRequired`** — column already exists and is unused; not wired, pending your call | decision, then code |
| — | **`BuyingOrder.VATMode`** — no column, never exported. VAT branch is written but unreachable | decision |
| — | Make `panel_boItem` price fields enterable + add a `taxable` control, so `recalcPrices()` has an event to fire on | decision, then code |
| O4/O5 | `Paid_date`/`Check_num`/`T_paid` placement; `Amt_outstanding` snapshot vs derive | you |

---

### Form field placement — DONE (this session)

`panel_boItem` now binds the migrated structure. Three kinds of change.

**1. New fields placed**

| Field | Page | Position | Bound to |
|---|---|---|---|
| Division | 0 | top 59, beside Vendor | `division.name` |
| Taxable | 1 | top 176, money column | `taxable` |
| Inventory | 1 | top 202 | `inventory` |
| Consumable | 1 | top 228 | `consumable` |
| Asset | 1 | top 254 | `asset` |

The classification trio sits under the money block because it is what decides GL treatment.
All four are checkboxes with `enterable: false` — the trio is derived from the GL account,
never user-set (§1d), and the rest of this form is display-only.

**2. A binding C1 missed**

`Field_hdr_vend` on page 0 still read `buyingOrder.customer.name`. C1 recorded four places
repointed to `supplier.name`; this was a fifth. It is now correct.

**3. Thirteen bindings pointed at `current_item.moreInfo.*`, which does not exist**

`moreInfo` appears nowhere in the project — the attribute is `moreData`. Every one of those
fields rendered blank. Repointed, and in the process several turned out not to belong in the
legacy bag at all:

| Object | Was | Now |
|---|---|---|
| `field_check_number` | `moreInfo.legacy.checkNumber` | **column** `checkNumber` |
| `field_date_paid` | `moreInfo.legacy.datePaid` | **column** `paidDate` |
| `field_invoice_date4` | `moreInfo.legacy.totalPaid` | **column** `amountPaid` — `totalPaid` was deleted in U3, so this field pointed at a dropped column |
| `field_asset_list_number` | `moreInfo.legacy.assetListNumber` | **column** `assetListNumber` |
| `field_supplier_ps_number` | `moreInfo.legacy.supplierPSNumber` | **column** `supPsNumber` |
| `field_record_number` | `moreInfo.legacy.recordNumber` | **column** `legacySeqNum` |
| `field_bill_date` | `moreInfo.legacy.billDate` | `moreData.legacy.billRecognitionDate` (key name differed) |
| `field_balance` | `moreInfo.legacy.balance` | `moreData.legacy.amountOutstanding` (key name differed) |
| `Field_return_to_vendor1` | `moreInfo.legacy.returnToVendor` | `moreData.pendingWorkflow.returnToVendor` |
| `field_invoice_date1` · `field_invoice_number` · `field_unique_id` | `moreInfo.legacy.*` | `moreData.legacy.*` |

Relation-backed fields repointed too: `Field_Part_num` → `aml.ourPartNum`,
`Field_Vendor_partnum` → `aml.vendorPartnum`, `Field_Recd_by` → `receiver.fullName`,
`Field_ConfirmationDate` → the real `confirmationDate` column.

**Two controls left bound to nothing**, because neither has a home yet:

- `Field_virtual_inventory1` → `current_item.virtualInventory`, a column that does not exist.
  Blocked on the O1 decision. If you add the column it starts working as-is.
- `field_relational_string` → `relationalString`, dropped by decision in §4 and no longer
  imported. The control should probably be deleted; left in place rather than removing a
  form object unasked.

**Also noticed:** `assetListNumber`, `supPsNumber` and `confirmationDate` each appear on
**both** page 1 and page 2 (Receiving), bound to the same column twice. Pre-existing, left alone.

**Still not wired:** `recalcPrices()` has no trigger. The new Taxable checkbox is
`enterable: false` like everything else here, so there is still no edit event. Making the
price block enterable is the outstanding decision.

---

### Price editing wired — DONE (this session)

`recalcPrices()` now has a trigger. Three mechanisms had to line up.

**1. The `entryField_` prefix is the enterable rule**

`sfw_foundations.4dm:2579` does `OBJECT SET ENTERABLE(*; "@entryField@"; $isInModification)`,
so an object's *name* decides whether it follows the panel into modification mode. Setting
`enterable` by hand would have been overwritten on the next redraw. Three objects were
renamed instead:

`Field_UnitPriceWithSalesTax` → `entryField_UnitPriceWithSalesTax` ·
`Field_Taxable` → `entryField_Taxable` · `Field_Freight` → `entryField_Freight`

(freight is buyer-typed per §1d, so it belonged in this group regardless of the recalc).

**2. The framework never touches `focusable`**

It toggles `enterable` only. A field with `focusable: false` cannot be clicked into no matter
what `enterable` says — which is exactly how the existing display-only `entryField_*` objects
stay read-only. So `focusable: true` is what actually makes a field typeable, and it was set
on precisely five:

| Typeable now | Still display-only (`focusable: false`) |
|---|---|
| `unitPrice` · `unitPriceWithTax` · `taxable` · `qtyOrdered` · `freight` | `lineTotal` · `tax` · `glAccount` · `description` · the dates |

`lineTotal` and `tax` are now derived, so leaving them unfocusable matters: the framework
still flips their `enterable`, and only `focusable` keeps a buyer from typing over a computed
figure.

**3. Both an ObjectMethod file and a class function, per this panel's existing note**

Under dynamic-source rendering the ObjectMethods files do not run — `sfw_dynamicForm_script`
calls a class function carrying the object's name. Four fields therefore got both:
`ObjectMethods/entryField_*.4dm` (static) and `Function entryField_*()` on `panel_boItem`
(dynamic). Both paths land on one `lineAmountChanged()`, which calls the entity and enables
Save. Same shape as `panel_poLines.lineAmountChanged`.

A shared `_priceFieldChanged` guard checks the event code **and**
`sfw.checkIsInModification()` — without the second test, merely displaying a line would
rewrite its stored totals.

**One correction to `recalcLineTotal`**

It read `qty`; the panel edits `qtyOrdered`. It now reads `qtyOrdered` — matching
`panel_poLines.applyLineTotal`, which does the same calculation for a purchase-order line —
and assigns `qty` alongside it. Both carry the same legacy `QTY`, and `SupplierEntity` reads
`qty` for receiving totals, so they are kept equal rather than allowed to drift the moment a
buyer edits an order quantity.

**Unchanged:** VAT mode is still unreachable (`BuyingOrder.VATMode` does not exist), so in
practice only the Normal branch runs today. The wiring calls `recalcPrices()`, not the Normal
branch directly, so a VAT column is still a one-line change.

---

### First import run — results and fixes [2026-sep-26]

11,860 lines created, 0 failed.

| Lookup | Result |
|---|---|
| **receiver** | 6,432 linked · 5,428 with no `Recd_by` · **0 unmatched** — all 22 legacy employee codes resolved on `Staff.code` |
| **division** | **11,860 linked · 0 unmatched** |
| **AML** | **0 linked** of 1,371 |

**AML root cause: the table is empty, and the lookup is not at fault.**

`aml_export.json` does not exist — not in `Project/Data/imports/`, not anywhere on disk,
while every other export is present. The chain is:

```
legacy [AVL_Supplies] -> aml_export.json -> __import_data_avl_aml -> [AML] -> this lookup
```

The first link was never run. The legacy export code exists and is correct
(`__export_data_method.4dm:1149` does `ALL RECORDS([AVL_Supplies])` and writes the file);
it simply never executed. Same shape as the `_import_users` prerequisite.

**To resolve:** run the `[AVL_Supplies]` block of the legacy `__export_data_method`, copy
`aml_export.json` into `Project/Data/imports/`, then run `__import_data_avl_aml` — **read it
first**, it opens by dropping every `Contact` with `companyType = "Supplier"` — then re-run
`_import_buyOrders`.

#### Fix 1 — part-number fallback (`_amlPartKey`)

Even with `[AML]` populated, 271 lines would still have missed. Their `Part_num` is a code
with a description glued on:

```
CF-001    1.25   mil AL TANAKA
CF-001   1.25 mil Al   CCC
CF-001  1.25 mil AL
```

Three spellings of `CF-001`, none of which fold onto the AML row `CF-001`.

Folding now lives in one method, **`_amlPartKey`**, used on *both* sides of the lookup — the
same arrangement `_unitMatchKey` has for units, and for the same reason. It also replaces the
old inline fold, which stripped only spaces, hyphens and underscores; it now keeps
alphanumerics only, so periods, slashes and parentheses fold away too.

Passing `leadingCodeOnly` truncates at the first run of **two or more** spaces. A single
space is deliberately not a separator — `5972-13-BURN IN` and `SEE BELOW` are whole values,
not a code plus commentary.

The rule is unusually safe here: across all 1,371 lines it produces **64** leading codes, 63
of them the `CF-0NN` internal family and the 64th `N/A`, which matches no AML row. It fires
only after an exact match has missed, returns empty when there is no distinct leading code,
and is **counted separately** in the report (`also linked on leading code only`) so it can
never inflate the exact-match total unnoticed.

#### Fix 2 — three missing units

The run reported 10 lines whose unit had no `[Unit]` row: `Daily`, `Pair`, `Pc.`
Added to `_import_units` — `Pair` and `Daily` as their own rows (`Daily` beside `Yearly`,
both billing periods rather than quantities), and `Pc.` as an **alias** of `Pcs`, since
`_unitMatchKey` folds away the period and the case.

#### Two items left from the run, neither blocking

- **20 vendors missing** of 4,582 — names that do not normalise onto a `Supplier` row.
- **67 lines with `shipVia` = "On site (GAC)"** — not a carrier at all. Either it earns a
  `CustomerCarrier` row or it should be ignored deliberately; right now it is reported as a
  failure every run.

---

### AML export obtained — correction to the fallback [2026-sep-26]

`aml_export.json` now exists: **394 AVL records**, with `OUR_partnum`, `Supplier`,
`Vendor_partnum`, `Service`, `MakeInactive`. The legacy `__export_data_method` crashed before
reaching the AVL block (`GetDateTimeValueCompact` faulting on an uninitialised
`<>DatetimestampRef` inside the unrelated `// export tools` block); disabling the other
`If (True:C214)` sections got the AVL block to run.

**The file is in the wrong folder.** It is at `Project/imports/`; `__import_data_avl_aml`
reads `Folder(fk data folder).file("imports/aml_export.json")`, i.e. **`Project/Data/imports/`**.
That alone explains AML still being 0.

#### The one-sided fallback was wrong

The fallback documented above folded the **buy line** to its leading code and compared it
against AML's **full** key. That can never match, because AML spells its part numbers the
same way the buy lines do — **146 of its 394 rows carry a description glued onto
`ourPartNum`**, and the two sides word it differently:

```
AML       CF-015    LOCTITE ABLESTIK QMI2569
buy line  CF-015   LOCTITE ABLESTIK QMI2569
```

Simulated against the real export, the one-sided rule recovered **0** lines — not the 271
claimed when it was written. That figure counted buy lines with the "code + description"
shape and assumed the AML side would be clean. It is not.

**Fixed:** the fold is now applied to *both* sides. A second map, `$existingAMLByCode`, is
keyed on supplier + leading code, and the lookup tries it only after an exact match misses.

**Ambiguity guard:** 4 leading codes resolve to more than one AML row for the same supplier.
Those keys are stored as `""` and skipped — picking one would invent a link, which is worse
than leaving the line unmatched. Counted as `code ambiguous, skipped` in the report.

#### Predicted next run (simulated against both export files)

| | |
|---|---|
| AML linked (exact) | **613** |
| also linked on leading code only | **37** |
| code ambiguous, skipped | **3** |
| part not in AML for this supplier | **718** |
| no part number | 10,489 |

The 718 are genuine: AVL holds 394 rows against 598 distinct part numbers on the buy lines,
so a large remainder was never in AVL for that vendor. That is data, not a lookup defect.

The fallback is worth **37 lines**, not 271. It is kept because it is correct and separately
counted, but it is a marginal gain — the real win was the exact match, which was only ever
blocked by the missing file.

---

### Import run 2 — all lookups green [2026-sep-26]

Matched the simulation exactly.

| Lookup | Result |
|---|---|
| receivers | 6,432 linked · **0 unmatched** |
| divisions | 11,860 linked · **0 unmatched** |
| units | 7,901 linked · **0 unmatched** (was 10) |
| AML | **613 exact + 37 on leading code** · 3 ambiguous skipped · 718 not in AVL |

11,860 lines, 0 failed.

**The 718 are data, not a defect.** AVL holds 394 rows against 598 distinct part numbers on
the buy lines. Breaking them down:

- **695** — the part is not in AVL at all, under any supplier
- **23** — the part exists in AVL but under a *different* supplier

Only those 23 could be recovered, and only by dropping the supplier scoping, which is the
cross-vendor bug the Supplier decision exists to prevent. **No further code change is
warranted on this lookup.**

#### The import is complete

Everything `_import_buyOrders` was asked to do now works. Two cosmetic items remain in its
report, neither affecting data:

- **20 vendors missing** of 4,582 — names that do not normalise onto a `Supplier` row
- **67 lines with `shipVia` = "On site (GAC)"** — not a carrier. Either it earns a
  `CustomerCarrier` row or it should be excluded deliberately, so it stops being reported as
  a failure on every run.

---

### Form reorganised into sections [2026-sep-26]

`panel_boItem` page 1 had grown into three unaligned columns: the money fields sat at
top 46–254 *above* every section band, three bands existed with names like `header_bkgd1`
and none covered the right-hand column, and row pitch varied between 10 and 30 px.

**Now three columns of titled sections**, using the same band styling as
`panel_buyingOrder` (30 px rectangle, `#A2C6D8`, `sizingX: fixed`; title at band top + 7,
left + 6, 12 pt bold):

| Column | x | Sections |
|---|---|---|
| A | 0–494 | **Item Info** · **Dates** · **GL Classification** |
| B | 504–998 | **Pricing** · **Payment Data** |
| C | 1008–… | **Totals** · **Reference** |

Grouping follows what the fields mean rather than where they used to sit: the GL account
moved next to the classification trio it derives (`inventory` / `consumable` / `asset`),
`taxable` and `freight` joined Pricing where they are keyed, and the legacy identity values
gathered under Reference.

Bands renamed to say what they are — `bkgd_itemInfo`, `bkgd_pricing`, `bkgd_payment`,
`bkgd_dates`, `bkgd_classification`, `bkgd_totals`, `bkgd_reference`, `bkgd_receiving`.
Nothing referenced the old `header_bkgd*` / `lbl_paymentInfos*` names.

Uniform grid: labels and fields on a 30 px pitch, labels at column + 10, fields at
column + 190 (A) / + 190 (B) / + 190 (C), every field verified to sit inside its column and
below its section band, with no overlapping pairs.

**Page 2 (Receiving)** had no band at all; it now carries a **Receiving** section.

#### Dynamic sizing

`redrawAndSetVisible` was resizing `Field_Comments` on `FORM Get current page = 5` — an
object that does not exist, on a page that was removed when pages 3–5 were dropped. Dead
code, replaced.

Only **column C** follows the panel width, the same way `panel_buyingOrder` stretches
`header_bkgd11`. Widening the window grows the Totals and Reference bands instead of
leaving a strip of bare background; the new right edge is floored at 1450 (column C's fields
end at 1438) so narrowing can never pull a band back across column B or invert it. Page 2's
single band takes the full width, floored at 940.

#### Two labels that were lying

- `label_requestor1` read **"Taxable"** while sitting next to the `requisitionOnly`
  checkbox. Now "Requisition Only" — and there is a real Taxable control above it, so the
  two were genuinely confusable.
- Twelve labels still showed raw legacy column names (`Part_num`, `Glac`, `Qtyin`,
  `Recd_by`, `Sup_ps_num`, …). Renamed to match the readable labels already used elsewhere
  on the panel.

**Unchanged:** `Field_virtual_inventory1` and `field_relational_string` are placed in their
sections but still bound to nothing — the first waits on the O1 column decision, the second
was dropped in §4. Both are visible and blank until you decide.

---

# 9. Field-by-field recap [2026-sep-26]

Every legacy `[BUY_ITEMS]` field and where it ended up. Status: **DONE** = migrated and
verified by the import run · **OPEN** = waiting on a decision or an action.

## 9.1 Real columns, populated by `_import_buyOrders` — DONE

| Legacy | Column | Note |
|---|---|---|
| `PO_NUM` | `boNumber` | |
| `QTY` | `qty` + `qtyOrdered` | kept equal; `recalcLineTotal` maintains that |
| `Unit_Price` | `unitPrice` | editable, drives the recalc |
| `UnitPriceWithSalesTax` | `unitPriceWithTax` | editable, drives the recalc in VAT mode |
| `Taxable` | `taxable` | editable |
| `TAX` | `tax` | derived |
| `Line_total` | `lineTotal` | derived, tax-inclusive |
| `Freight` | `freight` | editable, sits outside `lineTotal` |
| `Description` | `description` | |
| `Item` | `number` | now also a listbox column, "BO Item #" |
| `Units` | `units` + `UUID_Unit` | |
| `Date_required` | `requiredDate` | |
| `Date_in` | `dateIn` | |
| `Order_Date` | `orderDate` | |
| `ConfirmationDate` | `confirmationDate` | |
| `Qtyin` | `qtyReceived` | |
| `Inventory` | `inventory` | |
| `Consumable` | `consumable` | |
| `Asset` | `asset` | |
| `Glac` | `glAccount` | |
| `Assetlist_num` | `assetListNumber` | |
| `Sup_ps_num` | `supPsNumber` | |
| `Int_jobnum` | `jobNumber` + `UUID_Job` | |
| `Seq_Number` | `legacySeqNum` | also kept in the legacy bag |
| `Paid_date` | `paidDate` | O4 resolved: left as a column |
| `Check_num` | `checkNumber` | O4 resolved |
| `T_paid` | `amountPaid` | O4 resolved |
| `Comments` | notes feature (`sfw_Comment`) | 38,418 notes created |

## 9.2 Relations — DONE

| Legacy | FK | Relation | Run result |
|---|---|---|---|
| `Recd_by` | `UUID_Staff` | `receiver` → `Staff` | 6,432 linked, **0 unmatched** |
| `Division` | `UUID_Division` | `division` → `Division` | 11,860 linked, **0 unmatched** |
| `Part_num` + `Vendor_partnum` | `UUID_AML` | `aml` → `AML` | 613 exact + 37 by code |
| `Vendor` | *(via the order)* | `buyingOrder.supplier` | Supplier, not Customer |

## 9.3 `moreData.legacy.*` — read-only bag, DONE

Accounting fields whose module does not exist yet, plus legacy identity keys:

`invoiceNumber` · `invoiceDate` · `billRecognitionDate` · `payAmount` · `amountOutstanding` ·
`okToPay` · `multiChecks` · `lastPayDate` · `payBefore` · `disputedInvoice` · `discountDays` ·
`invalid` · `checkFlag` · `exception` · `seqNumber` · `uniqueID` · `dateTimeStamp` ·
`creationDateTimeStamp` · `comments` · `units` · `partNumber` · `vendorPartNumber`

The last two are the §4 deviation: kept for reconciliation because AML only matches ~47% of
the lines that carry a part number.

## 9.4 `moreData.pendingWorkflow.*` — DONE as far as it can go

`returnToVendor` — the vendor-returns workflow does not exist in GA. Displayed read-only
under **Reference** on the panel.

## 9.5 Dropped by decision — DONE

`Currency` (always US$) · `Vendor` (via the order) · `RelationalString` ·
`DocumentsinDocServer` (framework Documents) · `Invalid` · `Exception` · `totalPaid` (column
deleted) · plus the 16 legacy fields that carry no data at all: `Accepted_by` `Discount`
`Disc_yes` `RMA_num` `Reason` `Ppays` `M1099` `Discount_rate` `Internal` `Requisition`
`LotStep_Number` `CreationID` `Credit` `CreditDTStamp` `AlternateCheckName` `RMA_Date`

## 9.6 OPEN — awaiting your action

| # | Item | What is needed | Cost of leaving it |
|---|---|---|---|
| 1 | **`Virtual_inventory`** | Add a `virtualInventory` boolean to `BuyingOrderLine` | **654 rows lost on every import re-run.** Disjoint from `inventory` (0 overlap in 11,860), so it is a real fourth state. The form control already exists and is bound, waiting. |
| 2 | **`CheckFlag`** | Decide: map to the existing unused `verificationRequired` column? | Sitting in the legacy bag. Evidence is strong — 647 of 654 virtual-inventory rows, never true elsewhere. ~10 min of work once decided. |
| 3 | **`BuyingOrder.VATMode`** | Decide: add the column, or declare VAT mode dead | The VAT branch of `recalcPrices` is written but unreachable. No column, never exported, no VAT key anywhere in the 22 MB export. |
| 4 | **`field_relational_string`** | Delete the control | Renders permanently blank under **Reference**. |
| 5 | **U4 `Contact → Supplier`** | Add the relation on `Contact.UUID_Company` | Blocks the Phase 4 contact migration only. The import already writes Supplier UUIDs into that field. |
| 6 | **U5 `Contact → Customer`** | Optional: rename the relation, currently `auditStatus` | Cosmetic but confusing. |
| 7 | **Price recalc** | Open a buy item, edit a unit price, confirm the totals move | **Never executed.** The only part of this work with no runtime verification. |
| 8 | **20 vendors missing** | Names that do not normalise onto a `Supplier` row | Those orders have no vendor link. |
| 9 | **`shipVia` "On site (GAC)"** | Give it a `CustomerCarrier` row, or exclude it deliberately | 67 lines reported as a failure on every run. |

## 9.7 OPEN — found while fixing the vendor link

| # | Finding |
|---|---|
| 10 | **`BuyingOrderLine.UUID_Supplier` exists** (id 29, relation `supplier`) and **nothing populates it**. `line.supplier` is empty on every row. Either the import should set it from the parent order, or it should be dropped — the order already resolves the vendor. |
| 11 | **Receiving entry's "Item #" column reads `order`, not `number`.** `order` is the import's running line counter; `number` is the legacy `Item` value, the real item number within the buy order. The Buy Items entry now shows `number` as "BO Item #" — the two entries disagree. |
| 12 | **`pup_supplier` / `drawPup_supplier` on `panel_buyingOrder` are dead code** — a correct Supplier picker that is not on the form and is never called. The live control is `Field_customerName`. Delete one or adopt the other. |
