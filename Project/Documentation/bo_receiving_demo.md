# Buy Order & Receiving — demo scenario

Covers the BO module as implemented today: buy order → approval → buy items (GL account,
approved part, pricing) → receiving (lots, quantities) → back-order split, plus what the
legacy import brought across.

Every record number below is a real record from your imported data, verified against the
export files. Nothing in this script relies on data you have to invent.

---

## 0. Before you demo

### Must be true

| # | Check | Why |
|---|---|---|
| 1 | GA has been **reopened** since the last code change | new forms and classes only load on open |
| 2 | `_import_glAccounts` has run | 404 accounts; without it every checkbox stays unlocked and the GL picker refuses |
| 3 | `_import_buyOrders` has run | 4,582 orders / 11,860 lines |
| 4 | `_import_inventory` has run against `Resources\exports\inventory_export.json` | 762 stock rows linked to buy lines. **Not** the `DataJson` copy — different key names, silently imports nothing useful |
| 5 | `__import_data_avl_aml` has run | 394 AML rows, 347 of them pickable |
| 6 | `_import_users` has run **and** profiles assigned | see the blocker below |

### Known blocker — check this first

**Signing an order requires the approver to be in the `CS` (Customer Service) profile.**
`panel_buyingOrder.signApprover` calls `Staff_isInUserProfile($code; "CS")` and refuses with
*"This user is not part of the Customer Service profile and cannot be set as Approver"*.

If `_import_users` has not been run, or no one is in that profile, **you cannot approve an
order in the demo**, and section 2 stops dead. Test it before the audience is in the room.

### Two things that will look odd unless you know

**Every imported order reads as approved.** Legacy stored the literal text `"Signed"` in
`Signature1/2`; the import parks those in `moreData.legacySignature1/2` and the approval
accessor falls back to them. 4,575 of 4,582 orders are approved. Only **7** are not — they
are listed in §5 and they are what you use to demo the refusal.

**`Received By` is blank on many legacy receipts.** A lot of legacy rows have no employee
code at all, so the field is genuinely empty, not broken.

---

## 1. The list — where everything starts

**Buying → Buy Items** and **Receiving → Buy Orders** are two views of the same
`[BuyingOrderLine]` table: the purchasing/AP view and the receiving view.

1. Open **Receiving → Buy Orders**.
2. Point out the **Item #** column — it reads `1`, and on split lines `1.1`, `1.2`.
3. Rows on a **grey background** are already received (`dateIn` filled).
4. Toggle the **Inventory** filter — 710 of 11,860 lines are inventory lines.

---

## 2. Create and approve an order

**Buying → Buy Orders → new.**

1. A new order gets the next `boNumber`, today's date, and status **Requisition**.
2. Pick a **Vendor** — use `SHINKO` or `KEYSIGHT TECHNOLOGIES`, both have AML parts.
3. Set a **Buy order limit**, e.g. `5000`.
4. **Leave it unsigned** and save. This is the record you will try to receive against in §6.
5. Then sign it: scan or enter an approver code in **Signature 1**, then **Signature 2**.

> **Talking point.** Legacy stored a `Requistion` boolean that a trigger recomputed on every
> save as `Signature1="" | Signature2=""`. It was a cache, not a decision. Here approval is
> derived from the two approver slots — nothing to fall out of step.

---

## 3. Add a buy item — the GL account drives everything

Open the order's line editor, or **Buying → Buy Items → new** and pick the order.

### 3a. Expense account locks inventory

1. Click the **GL Account** field. The picker lists only **purchasable** accounts — 318 of
   404. Income, Equity, Bank, AP and AR are excluded, as are inactive and sub-accounts.
2. Pick **`5110-1 OUTSIDE SERVICES`**.
3. **Inventory is greyed out. Consumable stays available.**

### 3b. Asset account unlocks it

1. Change the GL account to **`1036-0 INVENTORIES`**.
2. **Inventory becomes tickable; Consumable greys out.** Tick Inventory.

> **Talking point.** This is `SetBuyingFieldsBasedonGLacc` ported. An inventory line is one
> whose GL account is an asset account that is *not* a Fixed Asset. Verified against the
> data: all 710 legacy inventory lines sit on accounts that allow it — zero contradictions.

### 3c. Pick the approved part

1. Click **Part #** (or **Vendor Part #** — same picker, both are views of one AML row).
2. The list is **scoped to this order's vendor**, excluding service and inactive rows.
3. Pick one. **Both fields fill at once**, and the description follows if you left it blank.

> **Talking point.** This is the QA gate: you can only buy a part from a vendor approved to
> supply it. Legacy did the same with two parallel scrollable areas over
> `QUERY([AVL_Supplies]; Supplier = [BUY_ORDERS]VENDOR) & Service=False & MakeInactive=False`.

Try it on a vendor with no AML rows to see *"QA has no approved part for &lt;vendor&gt;"* —
legacy's *"QA has no entry for this part#"*.

### 3d. Pricing

1. Enter **Quantity 100** and **Unit Price 2.50**.
2. Tick **Taxable** — tax and line total recalculate.
3. Edit **Unit price with tax** instead and watch the net price back out of it.

> **Talking point.** One implementation on the entity, used by the panel, the PO panel and
> the import. Verified against 11,860 imported lines: `lineTotal` is tax-inclusive and
> `salesTaxRate` is a fraction, which is *not* what the original spec said — the data settled it.

### 3e. Notes and documents

Both tabs are the framework's built-in features. Legacy line comments were imported as notes.

---

## 4. Receive it — the happy path

**Receiving → Buy Orders**, find your line. Or use a real one: **BO 33544, item 1** —
SHINKO, 12,000 ordered, three vendor lots.

1. **Page 0** shows the identity strip: BO #, item #, vendor, division, and
   **Ordered / Received / Open**.
2. **Page 1 left** is "What was ordered" — all read-only. Receiving must not edit the purchase.
3. Set **Received By** (scan or type a staff code).
4. Go to the **Inventories** tab → **Actions → Add a Lot**.
5. Enter a **Vendor Lot #** and a **Qty**, confirm.

What happens: one `[Inventory]` record per lot, linked by `UUID_BuyingOrderLine`, carrying
part number from the AML, vendor from the supplier, units, division, currency, job and
receiver — all through links. Unit cost is copied deliberately, as a valuation snapshot.

6. Add a second lot. **Qty Received** climbs; it is derived, not typed.
7. Once the lots cover the ordered quantity, **Date Received stamps itself**.

For BO 33544 the imported lots are:

| Vendor Lot # | Received | On Hand |
|---|---|---|
| HS3399-A0331 | 12,000 | 5,000 |
| HS3399-A0332 | 0 | 5,000 |
| HS3399-A0333 | 0 | 2,000 |

> **Talking point.** Legacy identified a receipt's stock by parsing a string —
> `Stock_Num = PO_NUM + "_" + Seq_Number`, plus `_1`, `_2` per extra lot, with a `StockGroup`
> column repeating the parent. A foreign key replaces all of it. The string survives only as
> a searchable label.
>
> `Received` and `On Hand` are separate columns on purpose: 672 of the 762 imported receipts
> were consumed years ago. Summing on-hand stock would report a fully received line as zero.

---

## 5. The gates — try to break it

All of these come from one place, `BuyingOrderLineEntity.receivingBlockedReason`.

| Try | Expected refusal |
|---|---|
| Receive against your **unsigned** order from §2 | *"Buy order N has not been approved. Both approver signatures are required…"* |
| Receive against **BO 30681, 31890 or 34372** (real unapproved orders) | same |
| Add a lot on a **non-inventory** line | *"This is not an inventory line, so it does not produce stock…"* |
| Add a lot with **no Received By** | *"Please set the receiver on the Main tab before adding a lot"* |
| Add a lot with **no lot number or zero qty** | *"Please enter a Vendor Lot # and a Qty greater than zero"* |
| Receive a line that is **already fully received** | *"This line was fully received on dd/mm/yy"* |
| Put the order **on hold** or **close** it, then receive | *"…is on hold" / "…is closed"* |
| Add a lot **over** the outstanding quantity | asks to confirm the overage, then allows it |

> **Talking point.** Legacy spread these across `recv_mrp`'s `call_abort`, the form's On Load,
> and the save button. One accessor now answers "can this be received, and if not why",
> and both the panel and the menu action ask it.

---

## 6. Partial receipt → back-order

Use your own line from §3 (ordered 100).

1. Receive **60** — one lot of 60.
2. **Qty Received 60, Still Outstanding 40.** Date Received stays empty, so the line stays
   in the receivable list.
3. Click **Back-order remaining quantity** (also on the item Actions menu).
4. Confirm.

Result: the original line closes at 60 received, and a **new line appears with the same
item number**, carrying the remaining 40, unreceived and unbilled, linked back to its parent.

5. Show the **Item #** column: the child reads `1.1`.
6. On the child, **Back-order of item** shows `1`.

> **Talking point.** Legacy duplicated the record and added `0.1` to a *real-number* item
> field. A buy order is a document already sent to the vendor, so line 1 stays line 1 — the
> split is a parent link plus a generation counter, the same shape `[Lot]` already uses.
> The `1.1` label is still derived for display.

### The imported history

Open **BO 30443** — ECR LABORATORY, a real legacy chain:

| Item | Qty | Received | Date in |
|---|---|---|---|
| 1 | 6 | 6 | 18/03/2020 |
| 1.1 | 7 | 7 | 26/03/2020 |
| 1.2 | 1 | 1 | 27/03/2020 |
| 1.3 | 2 | 0 | *still open* |
| 2 | 43 | 43 | 17/04/2020 |

One PO line delivered in four instalments, the last still outstanding after four years.

> **Talking point.** Written naively, `Num("1.1")` into an integer column rounds to `1` —
> 162 rows across 66 orders would have collapsed onto duplicate item numbers. The import
> decomposes it and rebuilds the chain: **85 split children, 85 linked, 0 orphans.**

---

## 7. What the import actually achieved

Numbers to quote, all verified against the export files:

| | |
|---|---|
| Buy orders / lines | 4,582 / 11,860 |
| GL accounts | 404, of which 318 purchasable, 27 inventory-capable |
| Inventory rows | 14,718 — **762 linked to a buy line, 0 unmatched** |
| of which lot splits | 77 |
| Back-order chains rebuilt | 85 children, 0 orphans |
| Lines with a part number | 1,371 (710 inventory, 661 service) |
| Lines with no part at all | 10,489 — fields hidden rather than shown blank |

---

## 8. Not built yet — say it before you are asked

- **Receipt printing** (`InventoryReceipt` / `MaterialReceipt`)
- **Vendor returns / RMA** — GA's `RMA` table is customer-side
- **Accounting** — invoice, payment and AP fields are parked read-only in `moreData.legacy`
- **`virtualInventory`** — 654 legacy rows discarded on every import re-run, awaiting a column
- **Units cascade** from the AML row — blocked on a type mismatch, see the migration doc
- **Receiving does not enforce `inventory` from the GL account** — `applyGLAccountRules`
  only runs when someone picks an account through the picker

---

## 9. Caveat

**None of this has been compiled or executed.** It was written against the source and the
export data, and verified structurally — object names, attribute names, relations, JSON
validity, control-flow balance — but it has never been run in 4D. Walk the whole script
privately once before demoing it.
