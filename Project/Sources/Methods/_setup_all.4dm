//%attributes = {}
// _setup_all
// Fills a NEW, EMPTY data file with only what the application needs to work: the lists
// and parameters the code looks up, the users and profiles, the production library
// (operations, step templates, steps, specifications), the buying and inventory set-up,
// and the print templates. NO legacy business records: no customers, suppliers, purchase
// orders, jobs, lots, buy orders, inventory, quotes or price list (_import_all does those).
//
// Same engine as _import_all (_import_runSteps): sources are checked first, a missing one
// skips its step, the log is Project/imports/setup_all.txt on the server.
//
// USAGE
//   _setup_all                          everything, from the top
//   _setup_all("_import_stepTemplates") resume from that step
//   _setup_all(""; True)                REPLACE: run every step even on tables already filled
//
// KEEPS EXISTING DATA (the default)
// Most importers empty their table and recreate it: every record gets a new UUID, and
// everything linked to the old ones (QA trainings, audits, specifications, lots, quotes...)
// then points at nothing. Each such step lists the tables it empties ("wipes"); when one of
// them already holds records the step is skipped and reported as KEPT. The steps that only
// add what is missing (units, carriers, BO statuses and terms, profiles, quote step sets,
// print templates, GAF files and links, counters) always run. So on a new data file
// everything runs, and on an existing one only the empty tables are filled.
//
// SOURCES
//   project:  Project/imports in the project folder
//   data:     next to the .4DD file (the server's data folder): DataJson/, GAF/
//   Built in, nothing to copy: units, carriers, BO statuses and terms, profiles, teams,
//   operation types, quote step sets, Resources/4DWriteProPrintTemplates/*.4wp and
//   Resources/ga/referenceRecords/dfdLine.json.
//
// NOT HERE
// - _import_customers, _import_vendors, _import_steps_files, __import_data_avl_aml: the
//   customers and suppliers are business data. A new data file starts without them;
//   _import_all brings them over from the legacy app.
// - _ga_createSalesDocFolders: the Documents tab folders are created at startup.
// - sfw_Country, sfw_EventType, sfw_NotificationType, sfw_Setting: created by the code
//   the first time they are used.
// - the QA module's own lists (QcarOrigin, reject criteria, chart of accounts, transaction
//   types): owned by the QA developers, run their __import_data_* methods by hand.

#DECLARE($from : Text; $replace : Boolean)

var $steps : Collection

$steps:=[]

//---1. lists and parameters. __import_data_lists TRUNCATES Division, DivisionInfo and the
//      other lists: it goes first, before anything links to them.
$steps.push({method: "__import_data_lists"; needs: ["data:DataJson/divisionInfo_export.json"]; wipes: ["SalesTax"; "CustomerStatus"; "CustomerCarrier"; "ControllingDepartment"; "EquipmentLocation"; "Division"; "CICategory"; "YesNoQuestion"; "CIPriority"; "CIOrigin"; "CIHumanFactor"; "CIDisposition"; "Units"; "DocumentCategory"; "AuditStatus"; "ProcessType"; "DivisionInfo"; "StepTemplateLayout"]})
$steps.push({method: "_ga_seedDivisionInfo"; needs: []})
$steps.push({method: "BOStatus_seed"; needs: []})
$steps.push({method: "_import_units"; needs: []})
$steps.push({method: "_import_customerCarriers"; needs: []})
$steps.push({method: "_import_boTerms"; needs: []})
$steps.push({method: "__import_quote_param"; needs: ["data:DataJson/QuoteStatus_export.json"]; wipes: ["QuoteStatus"; "Revision"]})
$steps.push({method: "__import_lead_param"; needs: ["data:DataJson/LeadStage_export.json"]; wipes: ["InteractionMethod"; "InteractionOutcome"; "InteractionTrigger"; "InteractionType"; "LeadPriority"; "LeadNextStep"; "LeadStage"; "ServiceType"]})

//---2. people: profiles, teams, then accounts + Staff (and the full-access account)
$steps.push({method: "_import_userProfiles"; needs: []})
$steps.push({method: "__import_teams"; needs: []; wipes: ["Team"]})
$steps.push({method: "_import_users"; needs: ["project:users_export.json"]; wipes: ["Staff"]})

//---3. production library
$steps.push({method: "_import_operations"; needs: ["project:operations_export.json"]; wipes: ["Operation"]})
$steps.push({method: "__import_operationTypes"; needs: []; wipes: ["OperationType"]})
$steps.push({method: "_import_operationProcesses"; needs: ["project:operationProcesses_export.json"]; wipes: ["StepProcess"]})
$steps.push({method: "_import_certifications"; needs: ["project:certifications_export.json"]; wipes: ["Certification"]})
$steps.push({method: "_import_toolTypes"; needs: ["project:toolTypes_export.json"]; wipes: ["ToolType"; "Tool"]})
$steps.push({method: "_import_stepProperties"; needs: ["project:stepProperties_export.json"]; wipes: ["StepProperty"]})
$steps.push({method: "_import_stepAreas"; needs: ["project:stepAreas_export.json"]; wipes: ["StepArea"]})
$steps.push({method: "_import_specControl"; needs: ["project:specControl_export.json"]; wipes: ["Specification"]})
$steps.push({method: "_import_holdCodes"; needs: ["project:holdCodes_export.json"]; wipes: ["HoldCode"]})
$steps.push({method: "_import_stepTemplateLayouts"; needs: ["project:stepTemplateLayouts_export.json"]; wipes: ["StepTemplateLayout"]})
$steps.push({method: "_import_stepTemplateRules"; needs: ["project:stepTemplateRules_export.json"]; wipes: ["StepTemplateRule"]})
$steps.push({method: "_import_stepTemplates"; needs: ["project:stepTemplates_export.json"]; wipes: ["StepTemplate"; "StepTemplateToolType"; "StepTemplateCertification"]})
$steps.push({method: "_import_steps"; needs: ["project:steps_export.json"]; wipes: ["Step"; "StepSpecification"; "StepSpec"]})

//---4. buying set-up (GL accounts need the divisions, approvers need Staff)
$steps.push({method: "_import_glAccounts"; needs: ["project:glAccounts_export.json"]; wipes: ["GLAccount"]})
$steps.push({method: "_import_boApprovers"; needs: ["project:boApprovers_export.json"]; wipes: ["BOApprover"]})

//---5. inventory set-up
$steps.push({method: "_import_inventoryClassification"; needs: ["project:inventoryClassifications_export.json"]; wipes: ["InventoryClassification"]})
$steps.push({method: "_import_inventoryUnits"; needs: ["project:inventoryUnits_export.json"]; wipes: ["InventoryUnits"]})
$steps.push({method: "_import_warehouseBins"; needs: ["project:warehouseBins_levels.json"]; wipes: ["Bin"]})

//---6. quotes: the standard step sets (asks first)
$steps.push({method: "_seed_quoteStepSets"; needs: []})

//---7. documents and print templates
$steps.push({method: "_import_specFiles"; needs: ["data:GAF/"]})
$steps.push({method: "_import_gafLinks"; needs: ["project:gaf_step_links.json"]})
$steps.push({method: "Planning_seedPLTTemplate"; needs: []})
$steps.push({method: "_import_lotTraveller"; needs: ["project:dfd_lotTraveller.json"]})
$steps.push({method: "_ga_installHoldFormModels"; needs: []})
$steps.push({method: "_ga_installBuyOrderModel"; needs: []})

//---8. counters past the imported numbers
$steps.push({method: "_fix_sequences"; needs: []})

_import_runSteps("_setup_all"; $steps; $from; "setup_all.txt"; Not:C34($replace))
