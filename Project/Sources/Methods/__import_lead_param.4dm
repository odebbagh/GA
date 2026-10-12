//%attributes = {"executedOnServer":true}
// __import_lead_param -> report lines
// Replaces the lead and interaction parameter tables with their *_export.json from the data
// folder's DataJson. A table whose file is missing is left as it is. The interaction triggers
// keep their moreData (daysAfterLeadCreation...). The code expects the trigger LEAD_CREATION and
// the interaction types SCHEDULED, COMPLETED and CANCELED.
// Report: Project/imports/lead_param_import.txt.
#DECLARE()->$lines : Collection

$lines:=_import_paramTables(New collection:C1472(\
New object:C1471("table"; ->[InteractionMethod:55]; "dataclass"; "InteractionMethod"; "file"; "InteractionMethod_export.json"; "idField"; "levelID"); \
New object:C1471("table"; ->[InteractionOutcome:54]; "dataclass"; "InteractionOutcome"; "file"; "InteractionOutcome_export.json"; "idField"; "levelID"); \
New object:C1471("table"; ->[InteractionTrigger:53]; "dataclass"; "InteractionTrigger"; "file"; "InteractionTrigger_export.json"; "idField"; "levelID"; "withMoreData"; True:C214); \
New object:C1471("table"; ->[InteractionType:41]; "dataclass"; "InteractionType"; "file"; "InteractionType_export.json"; "idField"; "levelID"); \
New object:C1471("table"; ->[LeadPriority:38]; "dataclass"; "LeadPriority"; "file"; "LeadPriority_export.json"; "idField"; "levelID"); \
New object:C1471("table"; ->[LeadNextStep:40]; "dataclass"; "LeadNextStep"; "file"; "LeadNextStep_export.json"; "idField"; "nextStepID"); \
New object:C1471("table"; ->[LeadStage:39]; "dataclass"; "LeadStage"; "file"; "LeadStage_export.json"; "idField"; "stageID"); \
New object:C1471("table"; ->[ServiceType:36]; "dataclass"; "ServiceType"; "file"; "ServiceType_export.json"; "idField"; "levelID")\
); "lead_param_import.txt")
