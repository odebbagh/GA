//%attributes = {}
// _import_accounting
// ONE CLICK: brings the accounting from legacy into this data file, adapted to this application.
// The other half of legacy _export_accounting. At go-live:
//   1. legacy (production), after the last month is closed: run _export_accounting
//   2. copy the .json files it lists from its DataJson/ folder to Project/imports/ here
//   3. here: run _import_accounting (or _import_all, which runs the same steps at its end)
// Every step runs unattended (no question: {unattended: True}); their messages go to
// Project/imports/import_messages.txt, the run log to Project/imports/import_accounting.txt,
// and the last step compares the result with legacy's control totals
// (Project/imports/accounting_import_check.txt). Every step can be re-run: nothing is
// emptied, records are matched (account number, customer, invoice number, asset number).
// Needs the customers, jobs and suppliers already imported (_import_all does them first).
//
// THE STEPS, and the part of the accounting each one feeds
//   _import_glAccounts        chart of accounts + roles, buy lines linked        Phase 0
//   _import_paymentTerms      the usual payment terms                            Phase 1a
//   _import_customerAR        customers' terms, credit limit / hold, e-mail      Phase 1a
//   _import_bankAccounts      bank details and the default bank on the accounts  Phase 1c / 4
//   _import_openingBalances   the opening entry (balances at the month end),
//                             books locked on that date                          Phase 0
//   _import_openReceivables   the legacy invoices customers still owe            Phase 1f
//   _import_customerCredits   customer credits not applied yet (CusAdv), as
//                             legacy payments - no journal entry                 Phase 1b
//   _import_assets            fixed assets with their legacy depreciation        Phase 3
//   _import_accountingCheck   the comparison with legacy's control totals
// STILL TO COME, with their phase (the legacy files already hold their data):
//   _import_openPayables      the legacy bills still to pay (openingBalances_export.json,
//                             openPayables)                                      Phase 2
//
// USAGE
//   _import_accounting                          every step
//   _import_accounting("_import_openReceivables") resume from that step
#DECLARE($from : Text)

var $steps : Collection
var $auto : Object

$auto:={unattended: True}
$steps:=[]
$steps.push({method: "_import_glAccounts"; needs: ["project:glAccounts_export.json"]; args: $auto})
$steps.push({method: "_import_paymentTerms"; needs: []; args: $auto})
$steps.push({method: "_import_customerAR"; needs: ["project:customerAR_export.json"]; args: $auto})
$steps.push({method: "_import_bankAccounts"; needs: ["project:bankAccounts_export.json"]; args: $auto})
$steps.push({method: "_import_openingBalances"; needs: ["project:openingBalances_export.json"]; args: $auto})
$steps.push({method: "_import_openReceivables"; needs: ["project:openingBalances_export.json"]; args: $auto})
$steps.push({method: "_import_customerCredits"; needs: ["project:customerCredits_export.json"]; args: $auto})
$steps.push({method: "_import_assets"; needs: ["project:assets_export.json"]; args: $auto})
$steps.push({method: "_import_accountingCheck"; needs: ["project:accounting_export_manifest.json"]; args: $auto})

_import_runSteps("_import_accounting"; $steps; $from; "import_accounting.txt")
