# _import_accounting — taking the accounting over from legacy

Two scripts, one on each side. Both can be re-run as often as needed: nothing is deleted,
records are matched (account number, customer, invoice number, asset number).

## At go-live (production)

1. **Legacy, production:** post and close the last month (General Journal > Post, then Close).
2. **Legacy:** run `_export_accounting`. It asks for the month end the new books start from
   (it proposes the last closed one) and writes into `DataJson/`:

   | File | Content | Legacy method |
   |---|---|---|
   | `glAccounts_export.json` | chart of accounts and their roles | `_export_glAccounts` |
   | `openingBalances_export.json` | balance of every account at the month end, open invoices, open bills | `_export_openingBalances` |
   | `customerAR_export.json` | customers' terms, credit limit / hold, AR e-mail | `_export_customerAR` |
   | `customerCredits_export.json` | customer credits not applied to an invoice yet (account CusAdv) | `_export_customerCredits` |
   | `bankAccounts_export.json` | bank accounts, next check number, last reconciliation | `_export_bankAccounts` |
   | `assets_export.json` | fixed assets with their accumulated depreciation | `_export_assets` |
   | `accounting_export_manifest.json` | control totals checked by the import | `_export_accounting` |

3. Copy those files to `Project/imports/` of the new application.
4. **New application:** run `_import_accounting` (or `_import_all` on a new data file: its last
   block runs the same steps). It runs unattended and ends with a check against the control
   totals.
5. Read `Project/imports/accounting_import_check.txt` (ALL MATCH expected), then
   `open_receivables.txt` (the difference between the invoices still owed and the A/R
   account, to be explained by the accountant).

## What each import does to the data

| Step | Adapts legacy data to | Phase |
|---|---|---|
| `_import_glAccounts` | `GLAccount` (+ `defaultKey` roles), links buy orders / lines | 0 |
| `_import_paymentTerms` | the usual `PaymentTerm`s, Net 30 default | 1a |
| `_import_customerAR` | `Customer` terms ("Net N" from the legacy days), credit limit / hold, statement e-mail | 1a |
| `_import_bankAccounts` | `GLAccount.moreData.bank` on each bank account, role *Default bank* | 1c / 4 |
| `_import_openingBalances` | one *Opening balance* journal entry (balance sheet accounts only), books locked on that date | 0 |
| `_import_openReceivables` | the invoices still owed as `JobInvoice` *Posted in legacy* (with or without their job), amount due in `moreData.legacyAR` — nothing written to the books (already in the opening entry) | 1f |
| `_import_customerCredits` | one `CustomerPayment` *Posted*, `isLegacy`, per customer with a credit (amount = unapplied amount = the credit), details in `moreData.legacyCredit` — nothing written to the books (already in the opening entry, on CusAdv) | 1b |
| `_import_assets` | `Asset` (cost, life, dates, type, vendor), legacy accumulated depreciation in `moreData.legacy` | 3 |
| `_import_accountingCheck` | compares with the manifest: accounts, balance sheet totals, lock, open invoices, customer credits, banks, assets | — |

### `_import_customerCredits` (Phase 1b, Receive payment)

A customer credit is money a customer paid in advance, or paid too much, that is not applied
to an invoice yet. Legacy keeps it on the account with the role *Customer advance* (CusAdv):
a deposit with no invoice credits that account, applying it to an invoice debits it.

- **Reads** `customerCredits_export.json`: for each customer, credits minus debits on CusAdv up
  to the month end, per division; and the CusAdv balance to check against.
- **Writes** one legacy payment per customer with a credit, ready to be applied to an invoice
  in *Receive payment*. **No journal entry**: the money is already in the opening entry, on CusAdv.
- **Needs** `_import_customerAR` (finds the customer) and `_import_openingBalances` (the CusAdv
  balance it compares with) first.
- **Re-runnable**: a credit is matched by its key and updated; one imported before that is no
  longer in the file (used in legacy since) is set to 0 and marked `closedByImportAt`.
- **Report**: `Project/imports/customer_credits.txt` (the credits found, and the comparison
  with the CusAdv balance).

Still to come with their phase: `_import_openPayables` (the open bills, already in
`openingBalances_export.json`), Phase 2.

## Logs

- `Project/imports/import_accounting.txt` — the run (each step, done / skipped)
- `Project/imports/import_messages.txt` — what each step reported
- one report per step: `opening_balances.txt`, `customer_ar.txt`, `bank_accounts.txt`,
  `open_receivables.txt`, `customer_credits.txt`, `assets_import.txt`, `accounting_import_check.txt`

## Testing it before go-live

Run the same two scripts on a copy of legacy and a test data file. A re-run replaces the
opening entry (the lock it set is lifted and set again) and updates the rest in place.
