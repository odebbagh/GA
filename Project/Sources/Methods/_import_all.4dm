//%attributes = {}
// _import_all
// Fills an EMPTY data file from the legacy exports by running every importer in the order
// their links need. This list is the one place that knows the order: keep it up to date when
// an importer is added or changed. _setup_all runs only the set-up part of it (the lists,
// users and libraries the application needs, without the legacy business records): keep
// the two in step.
//
// Run it from a 4D Remote client (the normal mode) or in single-user. The importers that
// read the data folder are executedOnServer, so "data:" sources are checked on the server
// (_import_allSrv); the others run here and read Project/imports from this machine.
//
// SOURCES
//   project:  Project/imports (in the repo)
//   data:     the data folder, next to the .4DD. On a new data file, copy these into it from
//             the previous data folder first:
//               DataJson/   quote and lead parameters, quotes, buy order terms
//               imports/    suppliers_export.json, aml_export.json, partData_export.json
//               GAF/        the GAF form PDFs
//   A step whose required file is missing is skipped and reported. Nothing stops the run.
//
// USAGE
//   _import_all                         everything, from the top
//   _import_all("_import_customers")    resume from that step (after fixing a failed one)
//
// Each step shows its own message when it finishes, and a few ask first (quotes, price
// list, step sets, GAF files, GAF links). The log is written to
// Project/imports/import_all.txt after every step, so it shows where a run stopped.
//
// ORDER RULES
// - __import_data_lists first: it TRUNCATES Division, DivisionInfo, CustomerCarrier,
//   StepTemplateLayout, Units, DocumentCategory, ControllingDepartment and other lists.
//   Anything linked to those before it runs would point at nothing.
// - _import_division and _import_hk_workflow are NOT called: __import_data_lists already
//   creates GAC, and truncating Division again would unlink DivisionInfo and Staff.
//   The housekeeping steps of _import_hk_workflow are listed one by one instead.
// - people before anything that names a person (buy orders, approvers, inventory).
// - customers before step files, purchase orders and the receiver. _import_customers
//   truncates Customer, vendors included, so _import_vendors comes right after it.
// - purchase orders -> jobs (receiver) -> PO lines -> lots -> lot steps.
// - buy orders after Staff, Division, carriers, units, suppliers / AML and jobs.
//   GL accounts after buy orders (they back-link the lines).
// - _fix_sequences last: the imports write numbers without moving the counters.
//
// DELIBERATELY NOT RUN
// - __import_data_facilities, __import_data_users, __import_data_staff, _ga_createUsers:
//   they TRUNCATE sfw_User and Staff, i.e. every account _import_users made, yours included.
// - _import_jobsFromReceiver: older duplicate of _import_receiver (both truncate Job).
// - _ga_fillBarcodeDataField: renumbers moreData.barcodeData in every table, Staff badges
//   included.
// - _ga_createMoreDataFields: changes the structure, not the data.
// - the QA module's own legacy imports (__import_data_audit, _managementReview, _CIP,
//   _equipment, _creditMemo, __import_qa_sample...): owned by the QA developers, several
//   truncate shared tables. Run them by hand afterwards if needed.
// - _demo_*: demo data.

#DECLARE($from : Text)

var $steps : Collection

// The source check, the confirmation, the run and the log are in _import_runSteps,
// shared with _setup_all (the set-up only).

//===================================================================================
// THE ORDER
//===================================================================================
$steps:=[]

//---1. lists and parameters (truncating lists first)
$steps.push({method: "__import_data_lists"; needs: ["data:DataJson/divisionInfo_export.json"]})
$steps.push({method: "_ga_seedDivisionInfo"; needs: []})
$steps.push({method: "BOStatus_seed"; needs: []})
$steps.push({method: "_import_units"; needs: []})
$steps.push({method: "_import_customerCarriers"; needs: []})
$steps.push({method: "_import_boTerms"; needs: []})
$steps.push({method: "__import_quote_param"; needs: ["data:DataJson/QuoteStatus_export.json"]})
$steps.push({method: "__import_lead_param"; needs: ["data:DataJson/LeadStage_export.json"]})

//---2. people: profiles, then accounts + Staff (and the full-access account)
$steps.push({method: "_import_userProfiles"; needs: []})
$steps.push({method: "__import_teams"; needs: []})  // Sales, MRB, Buyers, Planners...: looked up by name
$steps.push({method: "_import_users"; needs: ["project:users_export.json"]})

//---3. housekeeping (the steps of _import_hk_workflow, without its Division drop)
$steps.push({method: "_import_operations"; needs: ["project:operations_export.json"]})
$steps.push({method: "__import_operationTypes"; needs: []})  // AI, BI, EI, FT, WS: step templates link to them
$steps.push({method: "_import_operationProcesses";needs: ["project:operationProcesses_export.json"]})
$steps.push({method: "_import_certifications"; needs: ["project:certifications_export.json"]})
$steps.push({method: "_import_toolTypes"; needs: ["project:toolTypes_export.json"]})
$steps.push({method: "_import_stepProperties"; needs: ["project:stepProperties_export.json"]})
$steps.push({method: "_import_stepAreas"; needs: ["project:stepAreas_export.json"]})
$steps.push({method: "_import_specControl"; needs: ["project:specControl_export.json"]})
$steps.push({method: "_import_holdCodes"; needs: ["project:holdCodes_export.json"]})
$steps.push({method: "_import_stepTemplateLayouts"; needs: ["project:stepTemplateLayouts_export.json"]})
$steps.push({method: "_import_stepTemplateRules"; needs: ["project:stepTemplateRules_export.json"]})
$steps.push({method: "_import_stepTemplates"; needs: ["project:stepTemplates_export.json"]})
$steps.push({method: "_import_steps"; needs: ["project:steps_export.json"]})

//---4. customers, vendors, then what points at them
$steps.push({method: "_import_customers"; needs: ["project:customers_export.json"]})
$steps.push({method: "_import_vendors"; needs: ["project:vendors_and_contacts_export.json"]})
$steps.push({method: "_import_steps_files"; needs: ["project:steps_files_export.json"]})
$steps.push({method: "__import_data_avl_aml"; needs: ["data:imports/suppliers_export.json"; "data:imports/aml_export.json"]})

//---5. customer orders and production
$steps.push({method: "_import_purchaseOrders"; needs: ["project:purchaseOrders_export.json"]})
$steps.push({method: "_import_receiver"; needs: ["project:receiver_export.json"]})
$steps.push({method: "_import_poItems"; needs: ["project:poItems_export.json"]})
$steps.push({method: "_import_lotinfo"; needs: ["project:lotinfo_export.json"]})
$steps.push({method: "_import_lotSteps"; needs: ["project:lotsteps_export.json"]})

//---6. buying
$steps.push({method: "_import_buyOrders"; needs: ["project:buyOrders_export.json"]})
$steps.push({method: "_import_glAccounts"; needs: ["project:glAccounts_export.json"]})
$steps.push({method: "_import_boApprovers"; needs: ["project:boApprovers_export.json"]})

//---7. inventory
$steps.push({method: "_import_inventoryClassification"; needs: ["project:inventoryClassifications_export.json"]})
$steps.push({method: "_import_inventoryUnits"; needs: ["project:inventoryUnits_export.json"]})
$steps.push({method: "_import_warehouseBins"; needs: ["project:warehouseBins_levels.json"]})
$steps.push({method: "_import_inventory"; needs: ["project:inventory_export.json"]})

//---8. quotes and prices (each one asks first)
$steps.push({method: "_import_quotesRun"; needs: ["data:DataJson/quotes.json"]})
$steps.push({method: "_import_priceList"; needs: []})
$steps.push({method: "_seed_quoteStepSets"; needs: []})

//---9. documents and print models
$steps.push({method: "_import_specFiles"; needs: ["data:GAF/"]})
$steps.push({method: "_import_gafLinks"; needs: ["project:gaf_step_links.json"]})
$steps.push({method: "Planning_seedPLTTemplate"; needs: []})
$steps.push({method: "_import_lotTraveller"; needs: ["project:dfd_lotTraveller.json"]})
$steps.push({method: "_ga_installHoldFormModels"; needs: []})
$steps.push({method: "_ga_installBuyOrderModel"; needs: []})

//---10. counters past the imported numbers
$steps.push({method: "_fix_sequences"; needs: []})

_import_runSteps("_import_all"; $steps; $from; "import_all.txt")
