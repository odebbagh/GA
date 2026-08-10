//%attributes = {}

// --- Housekeeping Data Import ---
// Imports all housekeeping data in dependency order.
// Run this single method to populate the full housekeeping module.

// Truncate all housekeeping tables (children first, then parents)
ds:C1482.StepFile.all().drop()
ds:C1482.StepSpecification.all().drop()
If (ds:C1482["StepSpec"]#Null:C1517)
	ds:C1482["StepSpec"].all().drop()
End if 
ds:C1482.Step.all().drop()
ds:C1482.StepTemplateToolType.all().drop()
ds:C1482.StepTemplateCertification.all().drop()
ds:C1482.StepTemplate.all().drop()
ds:C1482.StepTemplateLayout.all().drop()
ds:C1482.StepTemplateRule.all().drop()
ds:C1482.Specification.all().drop()
ds:C1482.StepProperty.all().drop()
ds:C1482.StepArea.all().drop()
ds:C1482.StepProcess.all().drop()
ds:C1482.Certification.all().drop()
If (ds:C1482["Tool"]#Null:C1517)
	ds:C1482["Tool"].all().drop()
End if 
ds:C1482.ToolType.all().drop()
ds:C1482.Operation.all().drop()
ds:C1482.Division.all().drop()
ds:C1482.HoldCode.all().drop()
If (ds:C1482["ContainerCode"]#Null:C1517)
	ds:C1482["ContainerCode"].all().drop()
End if 

// 1. Base enums and lookups (no dependencies)
_import_division
_import_operations
_import_operationProcesses
_import_certifications
_import_toolTypes
_import_stepProperties
_import_stepAreas
_import_specControl
_import_holdCodes

// 2. Step template supporting data
_import_stepTemplateLayouts
_import_stepTemplateRules

// 3. Step templates (depends on layouts, rules, divisions, operations)
_import_stepTemplates

// 4. Steps (depends on templates, areas, processes, properties, specifications)
_import_steps

// 5. Step files (depends on steps)
_import_steps_files

ALERT:C41("Housekeeping import complete.")
