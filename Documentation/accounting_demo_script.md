# Accounting demo script (Phase 0, legacy import, Phase 1a)

A live demo of the accounting module, step by step: what to click, what to say, what the
screen should show, and how to recover if something goes wrong. Written for a presenter who is
not an accountant: every word is explained the first time it appears.

Figures come from the test data: the mid-2024 legacy snapshot, imported on 16/11/2026, with the
books starting at **30/04/2024**.

---

## 0. Before the demo

### What has run already, and what has never run

| Part | Status | Rehearse |
|---|---|---|
| The books: Chart of Accounts, Journal Entries, Register, Trial balance, Closing date (Phase 0) | Tested: `_demo_check` "Ledger" and "Ledger data" pass | Once |
| Import from legacy (`_export_accounting` → `_import_accounting`) | Ran on 16/11/2026: ALL MATCH | Once |
| Register tab with the left ribbon, date pickers, Journal Entry ribbon | Compiled, never clicked through | **Twice** |
| Payment terms, customer "Accounts receivable" section | Compiled, never clicked through | **Twice** |
| **Invoice posting (Phase 1a): Post, edit, Unpost, Void, refusals** | **Never run** | **Three times, on a test data file first** |
| `_demo_check` "Invoice posting" | **Never run** | Run it before anything else (step 10) |
| The 151 legacy invoices on the Invoices screen | **Never looked at** | Check where they show (see step 9) |

**Rehearsal order:** step 10 (`_demo_check`) first. Then step 8 (posting) on a copy of the
data file, then the whole script once on the demo data file.

### Checklist (the morning of the demo)

1. 4D compiled, restarted. The **Accounting** menu shows only **Chart of Accounts** and
   **Journal Entries**.
2. `Project/imports/accounting_import_check.txt` says **ALL MATCH**.
3. Closing date = **30/04/2024**: Journal Entries > gear > *Closing date…*.
4. No leftover test entry: Journal Entries list shows the opening entry and nothing you don't
   want to show. Void any rehearsal entry, or restore the data file.
5. The demo jobs are in place (Customer Service > Invoices, or Jobs):

   | Job | Customer | Why | Expected |
   |---|---|---|---|
   | **11111** | ISOLINK INC. | The invoice we post | Shipped, process Environmental, 950.00, its PO has 8,627.61 left |
   | **11039** | MACOM Technology Solutions Inc. | "PO without money" refusal | Shipped, 3,400.00 on a PO with exactly 3,400.00 left |
   | **11070** | Anloy Technologies | "Not shipped" refusal | Not shipped, 7,500.00 |

   Totals and PO amounts come from the legacy export: **check them on screen during rehearsal**
   and write the real figures in the margin of this script.
6. Have open, in a text editor: `Project/imports/accounting_import_check.txt` and
   `Project/imports/open_receivables.txt`.
7. A second user window or a colleague is not needed: everything runs from one session.

---

## 1. The idea of the books (2 minutes, no clicking)

**Say:**

> "Every event that moves money — sending an invoice, getting paid, buying parts — is written
> in the company's books. The books are split into **accounts**: named buckets such as *Bank*,
> *Customers owe us*, *Sales*, *Rent*. The list of all buckets is the **chart of accounts**."

> "Every account belongs to one of five **families**:
> - **Assets**: what the lab owns or will receive — the bank account, the money customers owe,
>   the stock on the shelves, the testers.
> - **Liabilities**: what the lab owes — vendors, loans, sales tax collected for the state.
> - **Equity**: what belongs to the owners — their investment and the profit kept over the years.
> - **Income**: what the lab earns by testing — sales.
> - **Expenses**: what it spends to run — parts used, rent, bank fees.
>
> The first three describe *what we have on a given day*. The last two describe *how a period
> went*; they restart at zero every year."

> "Every event touches **at least two accounts**, because money always comes from somewhere and
> goes somewhere. A $25 bank fee lowers the bank **and** adds a $25 expense. Accountants write
> the two sides in two columns called **debit** (left) and **credit** (right). They don't mean
> good or bad — just left and right. The rule: assets and expenses grow on the left, the other
> three families grow on the right. In every event, **left total = right total**: that is how a
> missing side gets caught."

> "One event written that way is a **journal entry**: a date, a memo, and lines."

Optional slide or whiteboard — the bank fee:

| Account | Debit (left) | Credit (right) |
|---|---|---|
| Bank service charges (expense, grows) | 25.00 | |
| Bank 1010-0 (asset, shrinks) | | 25.00 |

---

## 2. The import from legacy (3 minutes)

> Tested: the import ran on 16/11/2026, ALL MATCH. In the demo, **show the result**; don't
> re-run it live unless you rehearsed it on this data file the same day.

**Say:**

> "The new books don't start empty: they start where the old application stops. Two scripts
> do the move. In the old application, `_export_accounting` asks one question — the last
> month that was checked and closed, here 30 April 2024 — and writes six files: the accounts,
> their balances on that date, the customers' payment terms, the bank accounts, the fixed assets,
> and a list of control totals. Here, `_import_accounting` reads them, adapts them to this
> application, and finally compares what it built with those control totals."

**Show:** `Project/imports/accounting_import_check.txt`.

**Expect:**

```
ALL MATCH
OK  GL accounts (at least): legacy 404 - here 404
OK  Accounts with a legacy role: legacy 29 - here 29
OK  Opening entry date: legacy 30/04/2024 - here 30/04/2024
OK  Assets at 30/04/2024: legacy 10,707,301.88 - here 10,707,301.88
OK  Liabilities: legacy 5,109,074.39 - here 5,109,074.39
OK  Equity: legacy 5,598,227.49 - here 5,598,227.49
OK  Trial balance balanced: yes
OK  Books locked up to: 30/04/2024
OK  Open legacy invoices: 151
OK  Their amount due: 929,174.52
OK  Bank accounts on their GL account: 3
OK  Assets: 267 - cost 10,093,514.08
```

**Say:**

> "Every line matched. Notice the three big numbers: what the lab owned on 30 April 2024 —
> 10,707,301.88 — equals what it owed, 5,109,074.39, plus what belongs to the owners,
> 5,598,227.49. That equation always holds in healthy books: owned = owed + owners' part."

> "At go-live we run the same two scripts on the production data, after the last month is
> closed. That's the whole migration of the accounting: one click on each side."

**If it goes wrong:** a line reads DIFFERENT → don't improvise; say "this is the check doing its
job" and move on. The import can be re-run: nothing is deleted, records are matched.

---

## 3. Chart of Accounts (4 minutes)

**Click:** Accounting > **Chart of Accounts**.

**Say:**

> "Here are the 404 buckets, taken over from the old application. Each line: the account
> number, its name, its type, its role, and today's balance."

> "The **number** tells you the family: 1xxx assets, 2xxx liabilities, 3xxx equity, 4xxx
> income, 5xxx direct costs, 6xxx and up expenses."

**Click:** the views menu (top left) > **Accounts with a role**. **Expect: 29 accounts.**

**Say:**

> "Some accounts have a **role**: *Accounts receivable*, *Sales*, *Sales tax payable*,
> *Retained earnings*… When an invoice is posted, it doesn't ask anyone which account to use:
> it takes the account that has the role it needs. That's how QuickBooks works, and we copied
> it."

**Click:** `1030-0 ACCOUNTS RECEIVABLE`.

**Expect (Account tab):** Type *Accounts Receivable*, Family **Asset**, Balance today
**1,173,458.40**, Role *Accounts receivable (what customers owe)*.

**Say:**

> "Accounts receivable is the money customers owe us. It's an asset: it's ours, we just haven't
> received it yet. Today the customers owe 1,173,458.40."

**Click:** `1010-0 CASH-CHECKING FRB` > tab **Register**.

**Say (while pointing at the blue band on the left):**

> "The **register** is the account's history, like a bank statement. On the left, the ribbon:
> the period, the balance before it, the debits and credits of the period, and the balance at
> the end. The list on the right is every movement."

**Click:** **Actions** (bottom of the ribbon) > **Since the start of the books**.

**Expect:** Balance before **0.00** · Debits **344,001.01** · Credits **0.00** · Balance at end
**344,001.01**. One line dated **30/04/2024**, type *Opening*, debit 344,001.01.
The note in the ribbon: *"Debit account: debits add to the balance, credits subtract."*

**Say:**

> "One line so far: the opening balance. Every deposit and every check will add a line here."

**Show the date pickers:** click the calendar next to **From**, pick 01/01/2024: the list reloads.

**Show a negative balance:** open `1505-0 ACCUM DEP.- MACHINERY & EQUIPMENTS`.
**Expect:** balance **−2,359,571.41**.

**Say:**

> "A negative balance on purpose. This account *reduces* the machines account next to it
> (`1500-0`, 3,350,400.08). The machines cost 3.35 million; 2.36 million of that value is
> already used up — that's what **depreciation** means. On paper they're worth about 990,000
> today."

**Optional:** try to delete `1030-0` → refused (it's used). "An account with history can only be
made inactive, never deleted."

**If it goes wrong:**
- The register is empty → the period is wrong: Actions > *Since the start of the books*.
- The ribbon doesn't fill the height after resizing → click another tab and back.

---

## 4. The opening entry and the trial balance (3 minutes)

**Click:** Accounting > **Journal Entries** > views > **Opening balances** > open the entry.

**Expect:** type *Opening balance*, dated **30/04/2024**, **47 lines**, Debits
**30,812,954.22**, Credits **30,812,954.22**, Difference **0.00** in green, and the message
*"Dated on or before the closing date (30/04/2024): the entry is locked."*

**Say:**

> "This one entry is the starting point: one line per account that had a balance on 30 April
> 2024. The bank on the left, the loans on the right, and so on. Left total = right total:
> 30,812,954.22 on both sides. It's locked, so nobody can change the starting point by
> accident."

> "Why only 47 lines when there are 404 accounts? Only accounts with a balance appear, and only
> the 'what we have' families. Income and expenses start at zero in the new books — last year's
> profit is already inside the owners' part."

**Click:** gear (bottom left) > **Trial balance…** > **As of** = 30/04/2024 (calendar).

**Expect:** *"Totals: debits 30,812,954.22 credits 30,812,954.22 - balanced"* in green.
A few lines to point at:

| Account | Debit | Credit |
|---|---|---|
| 1010-0 CASH-CHECKING FRB | 344,001.01 | |
| 1030-0 ACCOUNTS RECEIVABLE | 1,173,458.40 | |
| 1505-0 ACCUM DEP.- MACHINERY & EQUIPMENTS | | 2,359,571.41 |
| 2001-0 ACCOUNTS PAYABLE | | 112,264.10 |
| 3501-0 RETAINED EARNINGS - YEAR TO DATE | | 21,578,061.14 |

**Say:**

> "The **trial balance** is every account's balance on one date, in two columns. If the two
> totals are equal, the books are consistent. It's the first report an accountant looks at."

**Click:** **Excel…** → open the file. "Every report goes to Excel."

**If it goes wrong:** totals differ → someone typed an entry on that date; Journal Entries
list, void it (step 5).

---

## 5. A manual entry: the bank fee (4 minutes)

**Click:** Journal Entries > **New**.

**Expect:** Type *Manual*, date = today, Difference 0.00, Problems in red:
*"An entry needs at least two lines (one account receives, another gives)."*, Save disabled.

**Say:**

> "Let's record a $25 bank fee by hand — the bank took it from our account."

**Click:** memo *Bank fee*. Line 1: **Account #** `1010-0`, **Credit** `25`.

**Expect:** the account name appears; Difference **−25.00** in red; Problems:
*"Debits (0.00) and credits (25.00) differ by 25.00."*

**Say:**

> "The bank account goes down: that's a credit for an asset. Now the screen tells me the entry
> is unbalanced — one side is missing."

**Click:** line 2: Account # `6260-0` (BANK SERVICE CHARGES), then **Actions** > **Put the
difference on this line**.

**Expect:** Debit 25.00 on line 2, Difference **0.00 in green**, Problems empty, **Save** active.

**Say:**

> "The expense grows by 25 — a debit. Left = right, the screen turns green, and only now can I
> save. Wrong entries simply can't be saved."

**Click:** **Save**. **Expect:** the entry gets the next number (write it down: #___).

**Click:** Chart of Accounts > `1010-0` > Register > Actions > **This fiscal year**.

**Expect:** Balance before **344,001.01** · Credits **25.00** · Balance at end **343,976.01**,
one line, today, credit 25. Double-click the line → the entry opens.

**Void it:** back in Journal Entries, select the bank-fee entry, make sure the mode (bottom
bar) is **Visualization**, not Modify, then **Actions** > **Void the entry**.

**Expect:** *"Void journal entry #N (25.00)? Its amounts will no longer count. It stays in the
list, marked void."* → **Void**. Status *Void*, the number stays. The register of 1010-0 is back
to **344,001.01**.

**Say:**

> "In accounting you never delete. A mistake is **voided**: its amounts stop counting, but the
> entry stays with its number, so nothing ever disappears without a trace."

**If it goes wrong:**
- "Void the entry" is greyed → you are in Modify: Save or Cancel, then switch the mode to
  **Visualization** (bottom bar).
- Typing a name instead of a number in Account # works only if one account matches; otherwise
  use Actions > *Pick the account…*.

---

## 6. The closing date (2 minutes)

**Click:** Journal Entries > **New** > pick date **15/04/2024** with the calendar.

**Expect:** Problems: *"The books are closed up to 30/04/2024: nothing dated 15/04/2024 can be
written or changed."* Save stays disabled. → **Cancel**.

**Say:**

> "Once a month is checked and reported — to the bank, the tax office, the owners — it's
> **closed**. Nothing dated in it can change any more, so the numbers already given out stay
> true. Today the books are closed up to 30 April 2024."

**Show:** gear > **Closing date…** → it shows *"Closed up to April 30, 2024."* (the long date format of the machine) → **Cancel**.

> Do NOT change the closing date live unless you rehearsed it: moving it back asks to confirm a
> *Reopen*, and you must set it back to 30/04/2024 afterwards.

---

## 7. Payment terms and the customer's A/R section (3 minutes)

> Never clicked through: rehearse twice.

**Click:** Administration > **Payment terms**.

**Expect:** Due on receipt, Net 15, **Net 30 (Default ticked)**, Net 45, Net 60, 2% 10 Net 30,
plus any "Net N" created from legacy customers.

**Say:**

> "**Terms** say when an invoice must be paid. *Net 30*: within 30 days of the invoice date.
> *2% 10 Net 30*: the customer may take 2% off if they pay within 10 days, otherwise the full
> amount within 30. Each term explains itself in a sentence — open one."

**Click:** *2% 10 Net 30* → read the explanation line aloud.

**Click:** Customer Service > **Customers** > *ISOLINK INC.* > Main page, section
**Accounts receivable**.

**Expect:** Terms (*"Default (Net 30)"* when the customer has none), Credit limit, Credit hold,
Hold reason, Statements to.

**Say:**

> "Each customer has its terms, a **credit limit** — how much they may owe us at most — and a
> **credit hold** to stop extending credit. Today a hold only warns when we post an invoice;
> later it will also warn at shipping. These came from the old application."

**Optional, rehearsed only:** tick **Credit hold** on ISOLINK, reason *Demo*, Save — the warning
appears in step 8. **Untick it after step 8.**

---

## 8. Posting an invoice (10 minutes) — never run: rehearse three times

### 8.1 The draft

**Click:** Customer Service > **Invoices** > view **Ready to invoices** > the invoice of
**job 11111**. If there is none: **New** > **Job** pop-up > 11111 > **Save**.

**Expect:** Status button **Draft** (grey dot), help text *"Draft: not in the books yet…"*,
Total about **950.00** (from the PO lines; check during rehearsal), Process *Environmental*.

**Say:**

> "An invoice says: *this customer owes us this much*. As long as it's a **draft**, it's only
> a document being prepared — the books know nothing about it. The moment we **post** it, it
> enters the books."

### 8.2 Post

**Click:** Save or Cancel, switch the mode (bottom bar) to **Visualization**, then **Actions** >
**Post the invoice…** (or click the **Draft** button > *Post the invoice…*).

**Expect** (read it aloud, it's written for that):

```
Post invoice <n> to the books?

ISOLINK INC. will owe 950.00, due <invoice date + the term's days> (<ISOLINK's term, else Net 30>).

Entry dated <invoice date>:
  Accounts receivable  debit 950.00
  Sales6GA - Environmental-GAC  credit 950.00

The job is marked invoiced and PO <n> billed +950.00.
```

(With a credit hold set in step 7: a *Warning: ISOLINK INC. is on credit hold: Demo.*)

**Say:**

> "Before writing anything, it shows exactly what it will write. Customers owe us 950 more —
> left side of accounts receivable. We earned 950 — right side of the sales account for the
> Environmental process, the same account the old application used. And the customer's
> purchase order is used up by 950."

**Click:** **Post**. **Expect:** *"Invoice <n> posted: journal entry #N."* Status **Posted**
(green), **Due**, **Terms** *Net 30*, **Posted** *16/11/2026 by <you>*.

### 8.3 What it wrote

1. Journal Entries > the new entry, type **Invoice**, read-only, help: *"Written by a document…"*.
   Two lines: 1030-0 debit 950.00 (with the customer), Sales6GA credit 950.00.
2. Chart of Accounts > `1030-0` > Register > Actions > *Since the start of the books*:
   new line debit 950.00, balance at end **1,174,408.40**.
3. Customer ISOLINK > POs tab: its PO's billed amount is 950.00 higher.

**Say:**

> "The invoice wrote its own entry. Nobody typed debits and credits: the document knows how to
> book itself. And from the books you can always find the invoice behind a number."

**Note for the presenter:** the entry is dated with the invoice date (May 2024 for this legacy
job), so use *Since the start of the books*, not *This fiscal year*, in the register. A trial
balance **as of today** shows the 950 inside *Retained earnings* (a 2024 income counts as past
years' profit in 2026); as of **31/05/2024** it shows on Sales6GA. Both total
**30,813,904.22** on each side.

### 8.4 Edit a posted invoice

**Click:** **Modify** > *Misc Other Charges Amt* = `100` > **Save**.

**Expect:** Total **1,050.00** (more if *Taxable* is ticked — then a tax line appears too),
same entry number, its lines now 1,050.00, PO billed +100.

**Say:**

> "While its month is open, a posted invoice can still be corrected; the entry follows. Once
> the month is closed, the invoice locks."

### 8.5 Unpost and Void

**Click:** (mode **Visualization**) Actions > **Unpost (back to draft)…** → read the confirmation →
**Back to draft**.

**Expect:** Status **Draft**; in Journal Entries the Invoice entry is **Void**; 1030-0 back to
**1,173,458.40**; PO billed back.

**Say:**

> "Unpost takes it out of the books: back to a draft, nothing lost."

**Void** — **on a rehearsal file only**, or say it without clicking: *Void the invoice…* cancels
it for good (the number stays, view **Void invoices**), and the job becomes billable again with a
new invoice.

For the rest of the demo, **post it again** (8.2) so the screen shows a posted invoice.

### 8.6 The refusals

**Job not shipped:** Invoices > **New** > Job **11070** (Anloy) > Save > Actions > *Post the
invoice…*

**Expect:**

```
Invoice <n> cannot be posted:
- Job 11070 is not shipped. Invoice not posted (legacy rule).
```

(If the new draft has no charges yet, a second line *"The invoice total is 0."* appears too:
both are refusals, both are fine to show.)

**Say:** "Same rule as the old application: you can't bill what you haven't shipped." Then
delete this draft (drafts can be deleted, posted ones can't).

**PO without money:** open the invoice of job **11039** (MACOM: 3,400.00 on a PO with exactly
3,400.00 left). Modify > Misc charges `100` > Save > Actions > *Post the invoice…*

**Expect:**

```
- PO <n> has not enough money left: it would be over by 100.00 (PO 3,400.00, already billed 0.00).
```

**Say:** "The customer only ordered 3,400 worth. We can't bill more than their purchase order."
Then Modify > Misc charges back to `0` > Save. (The refusal happened before anything was
written: the books and the PO are unchanged.)

**If it goes wrong in step 8:**
- "Post the invoice…" is greyed → the mode is Modify (switch to Visualization), or the
  invoice isn't a draft.
- *"The job has no valid customer PO"* → this job isn't linked to a PO in this data file: use
  another shipped job (Ready to invoices view).
- *"The books are closed up to 30/04/2024: an invoice dated … cannot be posted."* → the job's
  invoice date is old: set **Invoice Date** (calendar) to today, Save, post again.
- *"No account has the role Sales"* → Chart of Accounts, give the role *Sales* to 4001-0.
- Any 4D error dialog → **Abort**, say "first live run of this feature", go to step 9, and note
  the method and line for later.

---

## 9. The 151 legacy invoices and the 244,283.88 gap (3 minutes)

**Say:**

> "Besides the total, we brought the detail: which customer still owes which invoice. 151
> invoices, 929,174.52 in all. They're marked **Posted in legacy** (blue): already in the books
> through the opening balance, so read-only here."

**Show:** Invoices screen — search an invoice number (e.g. **8095**, Linear Microsystems,
6,000.00, dated 01/05/2023).

> **Check in rehearsal:** these invoices have no job (legacy archives a job once it's invoiced),
> and the views of the Invoices screen filter on job fields. If you can't find them in any view
> or by search, show `open_receivables.txt` instead and say a view for them comes with the next
> step (Receive Payment).

**Show:** `Project/imports/open_receivables.txt`.

**Expect:**

```
Open in the invoices: 929,174.52 - accounts receivable in the books (1030-0) at 30/04/2024: 1,173,458.40
Difference to explain: 244,283.88 - invoices whose net due and total - paid differ: 2
```

Biggest customers: Texas Instruments (Kifer Rd) 255,124.29 · Anadyne 68,978.00 · HRL
Laboratories 44,480.00 · SRI International 43,543.05 · Microsemi-SJ 36,150.41.

**Say:**

> "The accounts receivable account says customers owe 1,173,458.40. The invoices behind it add
> up to 929,174.52. 244,283.88 is not explained by any invoice. That's a question for the
> accountant before go-live: the old application had two 'amount due' fields that disagreed,
> and two invoices show it. The new books make the gap visible instead of hiding it."

---

## 10. The self-check: `_demo_check` (1 minute) — run it FIRST in rehearsal

**Click:** run the method `_demo_check`.

**Expect** — the three accounting lines PASS:

```
PASS  Ledger data: every journal entry balanced, accounts exist, accounts with the main roles
PASS  Ledger: post, balances, unbalanced entry refused, trial balance, closing date, void
PASS  Invoice posting: post, edit, unpost, void, not shipped / PO over refused
```

Other failures (demo people's profiles, traveller templates, GAF files, tool dates, default
assumptions) are missing demo data in this file, not accounting.

**Say:**

> "Before every demo the application tests itself: it builds throwaway accounts, a customer, a
> purchase order, a job and an invoice, posts, edits, unposts, voids — and then cancels
> everything, so the data is left as it was."

**If "Invoice posting" FAILS:** the detail line says what differs. Do not demo step 8; send the
line to the developer.

---

## 11. Closing words (1 minute)

> "What we have today: the books themselves, the starting point taken from the old application
> to the cent, and invoices that write their own entries. Next: receiving payments and applying
> them to invoices, deposits to the bank, credit memos, and the aging report — who owes what,
> and for how long."

---

## After the demo

- Void the demo entries you don't want to keep (the bank fee is already void).
- Untick ISOLINK's credit hold if you set it.
- Decide about job 11111's invoice: keep it posted, or Unpost it.
- Delete the 11070 draft if still there.

---

## Glossary (for questions from the audience)

| Word | Plain meaning | Lab example |
|---|---|---|
| Account | A named bucket of money | 1010-0 the FRB checking account |
| Chart of accounts | The list of all accounts | 404 accounts |
| Family | Asset, liability, equity, income, expense | 1030-0 is an asset |
| Debit / credit | Left / right column of an entry | Bank fee: debit expense, credit bank |
| Journal entry | One event in the books, left total = right total | The opening entry, 47 lines |
| Balance | What's in an account on a date | Bank 344,001.01 on 30/04/2024 |
| Contra account | An account that reduces another | Accumulated depreciation |
| Depreciation | Spreading the cost of equipment over its life | Testers lose value each month |
| Accounts receivable (A/R) | Money customers owe us | 1,173,458.40 |
| Accounts payable (A/P) | Money we owe vendors | 112,264.10 |
| Retained earnings | Profit of past years kept in the company | 21,578,061.14 |
| Trial balance | All balances on a date; the two totals must be equal | 30,812,954.22 each |
| Closing date | Locks a finished period | 30/04/2024 |
| Void | Cancel without deleting; the number stays | The bank fee |
| Post | Put a document in the books | The invoice for job 11111 |
| Terms | When an invoice is due | Net 30 |
| Credit limit / hold | Most a customer may owe / stop extending credit | Warning when posting |
| Role | The job an account does for the documents | 1030-0 = Accounts receivable |
