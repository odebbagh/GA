Class extends Entity

//local Function beforeSaveCreation()
//This._initCorrectiveActionReport()

local Function loadAfterCreation()
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470.qcarNumber:=ds:C1482.Qcar.all().max("qcarNumber")+1
	
local Function _initCorrectiveActionReport()
	This:C1470.correctiveActionReport:=New object:C1471(\
		"teamLearders"; ""; \
		"supervisor"; ""; \
		"teamMembers"; ""; \
		"d2"; ""; \
		"d3"; ""; \
		"d3TargetDate"; !00-00-00!; \
		"d3ActualDate"; !00-00-00!; \
		"d4"; ""; \
		"d5"; ""; \
		"d6"; ""; \
		"d6TargetDate"; !00-00-00!; \
		"d6ActualDate"; !00-00-00!; \
		"d7"; ""; \
		"d7TargetDate"; !00-00-00!; \
		"d7ActualDate"; !00-00-00!; \
		"controlPlan"; False:C215; \
		"training"; False:C215; \
		"flowchart"; False:C215; \
		"procWork"; False:C215; \
		"addToInternalAudit"; False:C215; \
		"others"; False:C215; \
		"othersText"; ""\
		)
	