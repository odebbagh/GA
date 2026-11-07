property current_item : cs:C1710.LeadEntity
singleton Class constructor
	
	
Function formMethod()
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		// the code, date and owner of a new lead are set in LeadEntity.loadAfterCreation: set here,
		// they were also written into every lead displayed without them, which sfw then took for a
		// change nobody made

		// another lead: its own contacts and no selected contact / interaction. The contacts were
		// only reloaded with the page, so a new lead could show those of the previous one
		Form:C1466.contact:=Null:C1517
		Form:C1466.current_interaction:=Null:C1517
		This:C1470.loadContacts()
		This:C1470.loadTabCounts()

		This:C1470.drawPup_serviceType()
		This:C1470.drawPup_stage()
		This:C1470.drawPup_priority()
		This:C1470.drawPup_customer()
		This:C1470.drawPup_staff()
		
		This:C1470.drawPup_nextStep()
		
		This:C1470.drawPup_quote()
		This:C1470.drawPup_po()
		This:C1470.drawPup_job()
		
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadContacts()
				
			: (FORM Get current page:C276(*)=2)
				Form:C1466.interactons_filters:=New object:C1471
				Form:C1466.interactons_filters.status:=New collection:C1472()
				Form:C1466.interactons_filters.trigger:=New collection:C1472()
				This:C1470._drawFilterTitle("status")  // the titles follow the reset filters
				This:C1470._drawFilterTitle("trigger")
				This:C1470.loadInteractions()
				
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadJobs()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	Case of 
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			// set by Lead_createQuote (item action): the lead now has its quote
			If (Bool:C1537(Form:C1466.refreshQuote))
				Form:C1466.refreshQuote:=False:C215
				This:C1470.drawPup_quote()
				This:C1470.loadTabCounts()
				If (FORM Get current page:C276(*)=2)
					This:C1470.loadInteractions()  // the quote's own follow-ups now show here too
				End if
			End if
			// set by LeadEntity.afterCreation: the new lead has its first follow-up
			If (Bool:C1537(Form:C1466.refreshCounts))
				Form:C1466.refreshCounts:=False:C215
				This:C1470.loadTabCounts()
				If (FORM Get current page:C276(*)=2)
					This:C1470.loadInteractions()
				End if
			End if
			This:C1470.drawPup_Interaction(["method"; "outcome"; "trigger"; "sales"; "contact"; "type"])
			This:C1470.display_interactionDetails()
			If (Form:C1466.current_interaction#Null:C1517)
				$index:=Form:C1466.current_interaction.indexOf()
				If ($index=-1)
					LISTBOX SELECT ROW:C912(*; "lb_interactions"; 0; lk remove from selection:K53:3)
				Else 
					LISTBOX SELECT ROW:C912(*; "lb_interactions"; $index+1; lk replace selection:K53:1)
				End if 
			Else 
				LISTBOX SELECT ROW:C912(*; "lb_interactions"; 0; lk remove from selection:K53:3)
			End if 
			
	End case 
	
Function btnDatePicker($object; $attribut)
	// the app's calendar (ga_datePicker), under the clicked button
	// Without parameters: the btnDatePicker button itself, called by sfw_dynamicForm_script
	// (the Documents page switches this panel to dynamic rendering)
	If (Count parameters:C259=0)
		If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.sfw.checkIsInModification())
			This:C1470.btnDatePicker(Form:C1466.current_item; "dateCreation")
		End if
		return
	End if
	If (cs:C1710.ga_datePicker.me.pickInto($object; $attribut))
		This:C1470._activate_save_cancel_button()
	End if 
	
Function loadInteractions()
	// the lead's interactions and those of its quote (ga_followUps.list)
	//Form.current_interaction:=Null
	
	$queryString:=""
	$settings:=New object:C1471("parameters"; New object:C1471)
	If (Form:C1466.interactons_filters.status.length#0)
		$queryString+="UUID_Type in :status"
		$settings.parameters.status:=Form:C1466.interactons_filters.status
	End if 
	If (Form:C1466.interactons_filters.trigger.length#0)
		If ($queryString#"")
			$queryString+=" and UUID_Trigger in :trigger"
		Else 
			$queryString+=" UUID_Trigger in :trigger"
		End if 
		$settings.parameters.trigger:=Form:C1466.interactons_filters.trigger
	End if 
	
	If ($queryString="")
		Form:C1466.lb_interactions:=cs:C1710.ga_followUps.me.list(Form:C1466.current_item).orderBy("stmpCreation desc, number desc").copy()
	Else 
		$queryString+=" order by stmpCreation desc, number desc"
		Form:C1466.lb_interactions:=cs:C1710.ga_followUps.me.list(Form:C1466.current_item).query($queryString; $settings).copy()
	End if
	This:C1470._countInteractions()  // a Cancel drops the interactions added meanwhile

Function loadTabCounts()
	// Row counts for the tab labels, worked out once per lead (formMethod) and not on every redraw:
	// lengths of entity selections only, nothing is loaded. Interactions: all of them, whatever the
	// filters; Jobs & Deliveries: all the customer's jobs, whatever the timing / period filters;
	// Documents: Form.nb_sfw_Documents, which the framework then keeps up to date on every upload,
	// model or delete (counted here as in sfw_definitionPageDocuments.refreshHTab)
	Form:C1466.tabCounts:=New object:C1471("interactions"; 0; "jobs"; 0)
	Form:C1466.nb_sfw_Documents:=0
	If (Form:C1466.current_item#Null:C1517)
		This:C1470._countInteractions()
		Form:C1466.tabCounts.jobs:=This:C1470._customerJobs().length
		Form:C1466.nb_sfw_Documents:=ds:C1482.sfw_Document.query("UUID_target = :1"; Form:C1466.current_item.UUID).length
		Form:C1466.nb_sfw_Documents+=ds:C1482.dfd_Document.query("UUID_target = :1"; Form:C1466.current_item.UUID).length
	End if

Function _countInteractions()
	If (Form:C1466.tabCounts=Null:C1517)
		Form:C1466.tabCounts:=New object:C1471("interactions"; 0; "jobs"; 0)
	End if
	Form:C1466.tabCounts.interactions:=(Form:C1466.current_item=Null:C1517) ? 0 : cs:C1710.ga_followUps.me.list(Form:C1466.current_item).length

Function _customerJobs()->$jobs : cs:C1710.JobSelection
	// every job of the lead's customer, linked to it or to one of its POs (an imported job can miss
	// one of the two)
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.customer#Null:C1517)
		$jobs:=ds:C1482.Job.query("UUID_Customer = :1 or purchaseOrder.UUID_Customer = :1"; Form:C1466.current_item.UUID_Customer)
	Else
		$jobs:=ds:C1482.Job.newSelection()
	End if

Function loadContacts()
	var $e_mainContact : cs:C1710.ContactEntity
	var $secondaryContacts : cs:C1710.ContactSelection
	
	$contacts:=New collection:C1472()
	If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.mainContact#Null:C1517)
		$e_mainContact:=ds:C1482.Contact.get(Form:C1466.current_item.moreData.mainContact.UUID)
		If ($e_mainContact#Null:C1517)
			$mainContact:=$e_mainContact.toObject()
			$mainContact.type:="Main"
			$contacts.push($mainContact)
		End if 
	End if 
	
	If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.secondaryContacts#Null:C1517)
		$secondaryContacts:=ds:C1482.Contact.query("UUID in :1"; Form:C1466.current_item.moreData.secondaryContacts)
		For each ($e_contact; $secondaryContacts)
			$contact:=$e_contact.toObject()
			$contact.type:="Secondary"
			$contacts.push($contact)
		End for each 
	End if 
	Form:C1466.lb_contacts:=$contacts  //Form.current_item.contacts()
	
Function loadJobs()
	// Jobs & Deliveries: every job of the lead's customer, linked to it or to one of its POs (an
	// imported job can miss one of the two), one row per job, newest first. The rows are worked out
	// once (JobEntity.jobsRow) and filtered in memory by the two buttons on the left.
	var $job : cs:C1710.JobEntity
	var $rows : Collection
	Form:C1466.job:=Null:C1517
	Form:C1466.job_position:=0
	$rows:=New collection:C1472
	For each ($job; This:C1470._customerJobs().orderBy("jobNumber desc"))
		$rows.push($job.jobsRow())
	End for each
	Form:C1466.jobs_all:=$rows
	If (Form:C1466.tabCounts#Null:C1517)
		Form:C1466.tabCounts.jobs:=$rows.length
	End if
	If (Form:C1466.jobs_filter=Null:C1517)
		Form:C1466.jobs_filter:=New object:C1471("timing"; "all"; "period"; "all")
	End if
	This:C1470._filterJobs()

Function _filterJobs()
	// the timing filter (delayed, on time, not shipped, on hold) and the period filter (on the date
	// delivered, else due) of the Jobs & Deliveries list
	var $rows : Collection
	var $from : Date
	$rows:=Form:C1466.jobs_all || New collection:C1472
	Case of
		: (Form:C1466.jobs_filter.timing="delayed")
			$rows:=$rows.query("daysLate > 0")
		: (Form:C1466.jobs_filter.timing="onTime")
			$rows:=$rows.query("timing = :1"; "On time")
		: (Form:C1466.jobs_filter.timing="notShipped")
			$rows:=$rows.query("isDelivered = :1 and status # :2 and status # :3"; False:C215; "Archived"; "Invoiced")
		: (Form:C1466.jobs_filter.timing="onHold")
			$rows:=$rows.query("status = :1"; "On hold")
	End case
	Case of
		: (Form:C1466.jobs_filter.period="week")
			$from:=Current date:C33-7
		: (Form:C1466.jobs_filter.period="month")
			$from:=Add to date:C393(Current date:C33; 0; -1; 0)
		: (Form:C1466.jobs_filter.period="quarter")
			$from:=Add to date:C393(Current date:C33; 0; -3; 0)
		: (Form:C1466.jobs_filter.period="year")
			$from:=Add to date:C393(Current date:C33; 0; 1-Month of:C24(Current date:C33); 1-Day of:C23(Current date:C33))
	End case
	If ($from#!00-00-00!)
		$rows:=$rows.query("refKey >= :1"; (Year of:C25($from)*10000)+(Month of:C24($from)*100)+Day of:C23($from))
	End if
	Form:C1466.lb_jobs:=$rows
	OBJECT SET TITLE:C194(*; "pupJobs_timing"; This:C1470._jobsFilterChoices("timing").query("key = :1"; Form:C1466.jobs_filter.timing).first().label)
	OBJECT SET TITLE:C194(*; "pupJobs_period"; This:C1470._jobsFilterChoices("period").query("key = :1"; Form:C1466.jobs_filter.period).first().label)

Function _jobsFilterChoices($filter : Text)->$choices : Collection
	If ($filter="timing")
		$choices:=New collection:C1472(New object:C1471("key"; "all"; "label"; "All jobs"); New object:C1471("key"; "delayed"; "label"; "Delayed"); New object:C1471("key"; "onTime"; "label"; "On time"); New object:C1471("key"; "notShipped"; "label"; "Not shipped"); New object:C1471("key"; "onHold"; "label"; "On hold"))
	Else
		$choices:=New collection:C1472(New object:C1471("key"; "all"; "label"; "All times"); New object:C1471("key"; "week"; "label"; "Last week"); New object:C1471("key"; "month"; "label"; "Last month"); New object:C1471("key"; "quarter"; "label"; "Last quarter"); New object:C1471("key"; "year"; "label"; "This year"))
	End if

Function _pickJobsFilter($filter : Text)
	// a filter of the Jobs & Deliveries list; works outside Modify (it only filters the view)
	var $menu; $choice : Text
	var $item : Object
	If (Form:C1466.jobs_filter=Null:C1517)
		Form:C1466.jobs_filter:=New object:C1471("timing"; "all"; "period"; "all")
	End if
	$menu:=Create menu:C408
	For each ($item; This:C1470._jobsFilterChoices($filter))
		APPEND MENU ITEM:C411($menu; $item.label; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $item.key)
		If ($item.key=Form:C1466.jobs_filter[$filter])
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"")
		Form:C1466.jobs_filter[$filter]:=$choice
		This:C1470._filterJobs()
	End if
	
	
	//mark:-draw and clic on popups
	//mark:Service type
Function drawPup_serviceType()
	If (Form:C1466.current_item#Null:C1517)
		$parts:=New collection:C1472(Form:C1466.current_item.serviceType.code; Form:C1466.current_item.serviceType.name)
		$serviceName:=$parts.join(" - "; ck ignore null or empty:K85:5)
		If ($serviceName="")
			$serviceName:=" "
		End if 
		$color:=cs:C1710.sfw_htmlColor.me.getName(Form:C1466.current_item.serviceType.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_serviceType"; $serviceName; $pathIcon; (Form:C1466.current_item.serviceType=Null:C1517))
	End if 
	
Function display_interactionDetails()
	OBJECT SET VISIBLE:C603(*; "interaction@"; Form:C1466.current_interaction#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "entryField_Inter_input@"; Form:C1466.current_interaction#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "Inter_input_number"; Form:C1466.current_interaction#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "btnDatePickerCreate@"; Form:C1466.current_interaction#Null:C1517)
	
	OBJECT SET ENTERABLE:C238(*; "entryField_Inter_input@"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENABLED:C1123(*; "entryField_Inter_input@"; Form:C1466.sfw.checkIsInModification())
Function drawPup_Interaction($widgets : Collection)
	var $item : Object
	For each ($widget; $widgets)
		$widgetName:="pup_"+$widget
		
		If (Form:C1466.current_interaction#Null:C1517)
			$widgetCapitalized:=cs:C1710.sfw_string.me.stringCapitalize($widget)
			$defaultName:="Select "+$widget
			$uuid:="UUID_"+$widgetCapitalized
			$cacheAttr:="interaction"+$widgetCapitalized
			
			
			OBJECT SET VISIBLE:C603(*; $widgetName; True:C214)
			Case of 
				: ($widget="sales")
					$name:=Form:C1466.current_interaction.staff=Null:C1517 ? "Select "+$widget : Form:C1466.current_interaction.staff.fullName
					
					
				: ($widget="contact")
					$name:=Form:C1466.current_interaction.contact=Null:C1517 ? "Select "+$widget : Form:C1466.current_interaction.contact.fullName
					
				Else 
					$dc:="Interaction"+$widgetCapitalized
					If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheAttr]=Null:C1517)
						ds:C1482[$dc].cacheLoad()
					End if 
					$items:=Storage:C1525.cache[$cacheAttr].query("UUID == :1"; Form:C1466.current_interaction[$uuid])
					
					If ($items.length#0)
						$name:=$items[0].name
					Else 
						$name:=$defaultName
					End if 
			End case 
			
			
			Form:C1466.sfw.drawButtonPup($widgetName; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; ($items.length=0))
			
		Else 
			OBJECT SET VISIBLE:C603(*; $widgetName; False:C215)
		End if 
	End for each 
	
	
	
	
	
Function pup_serviceType()
	var $eServiceType : cs:C1710.ServiceTypeEntity
	
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.serviceType=Null:C1517)
			ds:C1482.ServiceType.cacheLoad()
		End if 
		
		For each ($serviceType; Storage:C1525.cache.serviceType)
			APPEND MENU ITEM:C411($menu; $serviceType.code+" - "+$serviceType.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $serviceType.UUID)
			If ($serviceType.UUID=Form:C1466.current_item.UUID_ServiceType)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		
		Case of 
			: ($choose#"")
				Form:C1466.current_item.UUID_ServiceType:=$choose
		End case 
	End if 
	This:C1470.drawPup_serviceType()
	
	//mark:Stage
Function drawPup_stage()
	If (Form:C1466.current_item#Null:C1517)
		$leadStage:=ds:C1482.LeadStage.query("stageID= :1"; Form:C1466.current_item.currentStageID).first() || New object:C1471()
		$parts:=New collection:C1472($leadStage.code; $leadStage.name)
		$stageName:=$parts.join(" - "; ck ignore null or empty:K85:5)
		If ($stageName="")
			$stageName:="Stage"
		End if 
		$color:=cs:C1710.sfw_htmlColor.me.getName($leadStage.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_stage"; $stageName; $pathIcon; ($leadStage=Null:C1517))
	End if 
	
	
Function pup_stage()
	var $eLeadStage : cs:C1710.LeadStageEntity
	
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.leadStage=Null:C1517)
			ds:C1482.LeadStage.cacheLoad()
		End if 
		
		For each ($eLeadStage; Storage:C1525.cache.leadStage)
			APPEND MENU ITEM:C411($menu; $eLeadStage.code+" - "+$eLeadStage.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eLeadStage.UUID)
			If ($eLeadStage.stageID=Form:C1466.current_item.currentStageID)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		
		Case of 
			: ($choose#"")
				$eLeadStage:=ds:C1482.LeadStage.get($choose)
				Form:C1466.current_item.currentStageID:=$eLeadStage.stageID
				This:C1470.redrawAndSetVisible()  // W/L Reasons shows or hides at once, not on the next page switch
		End case 
	End if 
	This:C1470.drawPup_stage()
	
	
	//mark:Priority
	
Function drawPup_priority()
	If (Form:C1466.current_item#Null:C1517)
		$leadPriority:=ds:C1482.LeadPriority.query("levelID= :1"; Form:C1466.current_item.priorityLevelID).first() || New object:C1471()
		$parts:=New collection:C1472($leadPriority.code; $leadPriority.name)
		$priorityName:=$parts.join(" - "; ck ignore null or empty:K85:5)
		If ($priorityName="")
			$priorityName:="Priority"
		End if 
		$color:=cs:C1710.sfw_htmlColor.me.getName($leadPriority.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_priority"; $priorityName; $pathIcon; ($leadPriority=Null:C1517))
	End if 
	
Function pup_priority()
	var $eLeadPriority : cs:C1710.LeadPriorityEntity
	
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.leadPriority=Null:C1517)
			ds:C1482.LeadPriority.cacheLoad()
		End if 
		
		For each ($eLeadPriority; Storage:C1525.cache.leadPriority)
			APPEND MENU ITEM:C411($menu; $eLeadPriority.code+" - "+$eLeadPriority.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eLeadPriority.UUID)
			If ($eLeadPriority.levelID=Form:C1466.current_item.priorityLevelID)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		
		Case of 
			: ($choose#"")
				$eLeadPriority:=ds:C1482.LeadPriority.get($choose)
				Form:C1466.current_item.priorityLevelID:=$eLeadPriority.levelID
		End case 
	End if 
	This:C1470.drawPup_priority()
	
	//mark:Next Step
Function drawPup_nextStep()
	If (Form:C1466.current_item#Null:C1517)
		$leadNextStep:=Form:C1466.current_item.nextStep || New object:C1471()
		$parts:=New collection:C1472($leadNextStep.code; $leadNextStep.name)
		$leadNextStepName:=$parts.join(" - "; ck ignore null or empty:K85:5)
		If ($leadNextStepName="")
			$leadNextStepName:="Next step"
		End if 
		$color:=cs:C1710.sfw_htmlColor.me.getName($leadNextStep.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_nextStep"; $leadNextStepName; $pathIcon; ($leadNextStep=Null:C1517))
	End if 
	
	
Function pup_nextStep()
	var $eLeadNextStep : cs:C1710.LeadNextStepEntity
	
	
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.leadNextStep=Null:C1517)
			ds:C1482.LeadNextStep.cacheLoad()
		End if 
		
		For each ($eLeadNextStep; Storage:C1525.cache.leadNextStep)
			APPEND MENU ITEM:C411($menu; $eLeadNextStep.code+" - "+$eLeadNextStep.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eLeadNextStep.UUID)
			If ($eLeadNextStep.UUID=Form:C1466.current_item.UUID_LeadNextStep)  // currentNextStep does not exist
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		
		Case of 
			: ($choose#"")
				//$eLeadNextStep:=ds.LeadNextStep.get($choose)
				Form:C1466.current_item.UUID_LeadNextStep:=$choose
		End case 
	End if 
	This:C1470.drawPup_nextStep()
	
	//mark:Customer
Function drawPup_customer()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.customer.name || " "
		Form:C1466.sfw.drawButtonPup("pup_customer"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.customer=Null:C1517))
	End if 
	
	
Function selectCustomerOld()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				
				OBJECT GET COORDINATES:C663(*; "pup_customer"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				$form:=New object:C1471()
				$form.lb_items:=ds:C1482.Customer.all()
				$form.oo:=""
				
				$winRef:=Open form window:C675("selectCustomer"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectCustomer"; $form)
				CLOSE WINDOW:C154($winRef)
				If (ok=1)
					Form:C1466.current_item.UUID_Customer:=$form.item.UUID
					Form:C1466.current_item.deal:=True:C214
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					
					This:C1470._clearInfoAfterChangingCustomer()
					This:C1470.loadContacts()
				End if 
		End case 
	End if 
	This:C1470.drawPup_customer()
	
Function _clearInfoAfterChangingCustomer($previousCustomer : Text)
	// the contacts, quote, PO and job belong to the customer: cleared when it really changes (picking
	// the same customer again keeps them); the other moreData keys are kept
	var $moreData : Object
	If (Count parameters:C259>=1) && (Form:C1466.current_item.UUID_Customer=$previousCustomer)
		return
	End if
	$moreData:=(Form:C1466.current_item.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225(Form:C1466.current_item.moreData)
	OB REMOVE:C1226($moreData; "mainContact")
	$moreData.secondaryContacts:=New collection:C1472
	Form:C1466.current_item.moreData:=$moreData
	Form:C1466.current_item.UUID_Quote:=Null:C1517
	Form:C1466.current_item.UUID_PurchaseOrder:=Null:C1517
	Form:C1466.current_item.UUID_Job:=Null:C1517
	Form:C1466.contact:=Null:C1517
	This:C1470.loadContacts()  // the contacts were cleared, but the list still showed them
	If (Form:C1466.tabCounts#Null:C1517)
		Form:C1466.tabCounts.jobs:=This:C1470._customerJobs().length  // the Jobs & Deliveries tab follows the customer
	End if
	This:C1470.drawPup_quote()
	This:C1470.drawPup_po()
	This:C1470.drawPup_job()

	//mark:Staff
Function drawPup_staff()
	If (Form:C1466.current_item#Null:C1517)
		$staffName:=Form:C1466.current_item.staff.fullName || ""
		Form:C1466.sfw.drawButtonPup("pup_staff"; $staffName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.staff=Null:C1517))
	End if 
	
Function selectStaff()
	
	
	
	
	// the light list picker of the buy orders (selectNto1): the sfw selector was slow to open.
	// Changing the owner no longer clears the contacts, quote, PO and job (that is for the customer)
	var $form : Object
	var $winRef; $l; $t; $r; $b : Integer

	If (Form:C1466.sfw.checkIsInModification())
		OBJECT GET COORDINATES:C663(*; "pup_staff"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		$form:=New object:C1471(\
			"colName"; "fullName"; \
			"allData"; ds:C1482.Staff.query("terminated = :1 and inactive = :2"; False:C215; False:C215).orderBy("lastName asc"); \
			"dataclass"; "Staff")
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		If (OK=1) && ($form.item#Null:C1517)
			Form:C1466.current_item.UUID_Staff:=$form.item.UUID
			This:C1470._activate_save_cancel_button()
		End if
		This:C1470.drawPup_staff()
	End if
	
	
Function callbackAfterCreationOwner($key : Text)
	Form:C1466.current_item.UUID_Staff:=$key
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Staff)=True:C214)
		Form:C1466.current_item.UUID_Staff:=16*"00"
	End if 
	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_lead.me.drawPup_staff()); *)
	
	
	
	//mark:quote
Function drawPup_quote()
	If (Form:C1466.current_item#Null:C1517)
		$quoteName:=Form:C1466.current_item.quote.code || "Select quote"
		Form:C1466.sfw.drawButtonPup("pup_quote"; $quoteName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.quote=Null:C1517))
	End if 
	
Function drawPup_method()
	If (Form:C1466.current_item#Null:C1517)
		$quoteName:=Form:C1466.current_item.quote.code || "Select quote"
		Form:C1466.sfw.drawButtonPup("pup_quote"; $quoteName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.quote=Null:C1517))
	End if 
	
	
Function selectQuote
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item.customer.quotes.length>0)
		
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				
				OBJECT GET COORDINATES:C663(*; "pup_quote"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				$form:=New object:C1471()
				$form.lb_items:=Form:C1466.current_item.customer.quotes
				$form.current_item:=Form:C1466.current_item.customer.quotes
				$form.oo:=""
				
				$winRef:=Open form window:C675("selectQuote"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectQuote"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Quote:=$form.item.UUID
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
				End if 
				
		End case 
		
	End if 
	This:C1470.drawPup_quote()
	
	
	//mark:PO
Function drawPup_po()
	var $poName : Text
	If (Form:C1466.current_item#Null:C1517)
		$poName:=String:C10(Form:C1466.current_item.purchaseOrder.poNumber) || "Select PO"
		Form:C1466.sfw.drawButtonPup("pup_po"; $poName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.purchaseOrder=Null:C1517))
	End if 
	
	
Function selectPO()
	var $selector : cs:C1710.sfw_definitionSelector
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item.customer.purchaseOrders.length>0)
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				
				OBJECT GET COORDINATES:C663(*; "pup_po"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471()
				
				
				$form.lb_items:=Form:C1466.current_item.customer.purchaseOrders
				$form.current_item:=Form:C1466.current_item.customer.purchaseOrders
				$form.oo:=""
				
				$winRef:=Open form window:C675("selectPo"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectPo"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_PurchaseOrder:=$form.item.UUID
					Form:C1466.current_item.job:=Null:C1517
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
				End if 
				
		End case 
	End if 
	
	
Function subsetSelectorPurchaseOrders()->$esPO : cs:C1710.PurchaseOrderSelection
	
	$esPO:=This:C1470.current_item.customer.purchaseOrders
	
	//mark:Job
Function drawPup_job()
	var $jobName : Text
	var $poJob : cs:C1710.JobEntity
	If (Form:C1466.current_item#Null:C1517)
		$jobName:=String:C10(Form:C1466.current_item.job.jobNumber) || "Select job"
		// no job chosen yet: the job of the lead's PO, as a hint (the link is filled when the PO is
		// saved, ga_sales.syncLeadsFromPurchaseOrder; a job given its PO later is not seen until then)
		If (Form:C1466.current_item.job=Null:C1517) && (Form:C1466.current_item.purchaseOrder#Null:C1517)
			$poJob:=cs:C1710.ga_sales.me.jobsOfPurchaseOrders(ds:C1482.PurchaseOrder.query("UUID = :1"; Form:C1466.current_item.UUID_PurchaseOrder)).orderBy("jobNumber asc").first()
			If ($poJob#Null:C1517)
				$jobName:=String:C10($poJob.jobNumber)+" (from the PO)"
			End if
		End if
		Form:C1466.sfw.drawButtonPup("pup_job"; $jobName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.job=Null:C1517))
	End if
	
	
Function selectJob()
	
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_item.purchaseOrder#Null:C1517)
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				
				OBJECT GET COORDINATES:C663(*; "pup_job"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				$form:=New object:C1471()
				
				If (Form:C1466.current_item.purchaseOrder#Null:C1517)
					$form.lb_items:=Form:C1466.current_item.purchaseOrder.lineItems
				Else 
					$form.lb_items:=Form:C1466.current_item.customer.purchaseOrders.lineItems
				End if 
				If ($form.lb_items#Null:C1517)
					$form.lb_items:=ds:C1482.Job.query("UUID in :1"; $form.lb_items.distinct("UUID_Job"))
					$form.current_item:=$form.lb_items
					$form.oo:=""
					
					$winRef:=Open form window:C675("selectJob"; Pop up form window:K39:11; $l; $b+1)
					DIALOG:C40("selectJob"; $form)
					CLOSE WINDOW:C154($winRef)
					
					If (ok=1)
						Form:C1466.current_item.UUID_Job:=$form.item.UUID
						Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					End if 
				End if 
		End case 
	End if 
	This:C1470.drawPup_job()
	
	
	//Mark:-redraw
Function redrawAndSetVisible()
	var $notesRight; $notesBottom : Integer
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$verticalMargin:=3
	
	Case of 
		: (FORM Get current page:C276(*)=1)
			OBJECT GET COORDINATES:C663(*; "lb_contacts"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_contacts"; $g; $t; $r; $heightSubform)
			
			
			//OBJECT GET COORDINATES(*; "bar_history"; $g; $t; $r; $b)
			//OBJECT GET COORDINATES(*; "Rec_history"; $gh; $th; $rh; $bh)
			
			//OBJECT SET COORDINATES(*; "bar_history"; $g; $t; $widthSubform; $b)
			//OBJECT SET COORDINATES(*; "Rec_history"; $gh; $th; $widthSubform; $heightSubform)
			
		: (FORM Get current page:C276(*)=2)
			//OBJECT GET COORDINATES(*; "bActionInteractions"; $g; $t; $r; $b)
			//OBJECT SET COORDINATES(*; "bActionInteractions"; $g; $heightSubform-(2*($b-$t)-$verticalMargin); $r; $heightSubform-($b-$t)-$verticalMargin)
			OBJECT GET COORDINATES:C663(*; "bActionInteractions"; $g; $h; $d; $b)
			$heightButton:=$b-$h
			OBJECT SET COORDINATES:C1248(*; "bActionInteractions"; $g; $heightSubform-$verticalMargin-$heightButton; $d; $heightSubform-$verticalMargin)
			
			
			OBJECT SET ENABLED:C1123(*; "bActionInteractions"; Form:C1466.current_item.customer#Null:C1517)
			This:C1470.drawPup_Interaction(["method"; "outcome"; "trigger"; "contact"; "sales"; "type"])
			This:C1470.display_interactionDetails()
			
			OBJECT GET COORDINATES:C663(*; "Rectangle2"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "Rectangle2"; $g; $t; $r; $heightSubform)
			
			
			
			OBJECT GET COORDINATES:C663(*; "lb_interactions"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_interactions"; $g; $t; $r; $heightSubform)

			// the notes take the rest of the detail area, never less than in the form (left 936,
			// top 435, right 1341, 200 high). Constant left / top: the untyped variables of
			// OBJECT GET COORDINATES came back undefined here (error 15 on $t+200)
			$notesRight:=Num:C11($widthSubform)-20
			If ($notesRight<1341)
				$notesRight:=1341
			End if
			$notesBottom:=Num:C11($heightSubform)-20
			If ($notesBottom<(435+200))
				$notesBottom:=435+200
			End if
			OBJECT SET COORDINATES:C1248(*; "entryField_Inter_input_notes1"; 936; 435; $notesRight; $notesBottom)

		: (FORM Get current page:C276(*)=3)
			
			OBJECT GET COORDINATES:C663(*; "Rect"; $g; $t; $r; $b)
			OBJECT SET COORDINATES:C1248(*; "Rect"; $g; $t; $r; $heightSubform)
			
			OBJECT GET COORDINATES:C663(*; "lb_jobs"; $gj; $tj; $rj; $bj)
			OBJECT SET COORDINATES:C1248(*; "lb_jobs"; $gj; $tj; $widthSubform; $heightSubform)
			// Subcon price, Markup amount, Markup %, Process 2, Actual: no source in GA nor in the legacy
			// app; hidden until the client says where they come from
			OBJECT SET VISIBLE:C603(*; "Column16"; False:C215)
			OBJECT SET VISIBLE:C603(*; "Column17"; False:C215)
			OBJECT SET VISIBLE:C603(*; "Column8"; False:C215)
			OBJECT SET VISIBLE:C603(*; "Column15"; False:C215)
			OBJECT SET VISIBLE:C603(*; "Column5"; False:C215)
			
			
	End case 
	
	
	
	This:C1470.drawPup_serviceType()
	This:C1470.drawPup_stage()
	This:C1470.drawPup_priority()
	This:C1470.drawPup_customer()
	This:C1470.drawPup_staff()
	
	This:C1470.drawPup_nextStep()
	
	This:C1470.drawPup_quote()
	This:C1470.drawPup_po()
	This:C1470.drawPup_job()
	
	// W/L Reasons only on a won or lost stage (LeadStage.moreData.outcome, see LeadStage.outcomeOf),
	// with its label
	$isClosed:=(ds:C1482.LeadStage.outcomeOf(Form:C1466.current_item.currentStageID)#"")
	OBJECT SET VISIBLE:C603(*; "entryField_reasonWL"; $isClosed)
	OBJECT SET VISIBLE:C603(*; "label_0_9"; $isClosed)
	OBJECT SET ENABLED:C1123(*; "pup_quote"; (Form:C1466.current_item.customer.quotes.length>0))
	OBJECT SET ENABLED:C1123(*; "pup_po"; (Form:C1466.current_item.customer.purchaseOrders.length>0))
	OBJECT SET ENABLED:C1123(*; "pup_job"; (Form:C1466.current_item.purchaseOrder#Null:C1517))
	This:C1470.display_interactionDetails()

	// record counts in the tab labels, as in the other panels. Read from Form.tabCounts and
	// Form.nb_sfw_Documents (loadTabCounts): this runs on nearly every form event, no query here
	var $counts : Object
	$counts:=Form:C1466.tabCounts || New object:C1471()
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Interactions ("+String:C10(Num:C11($counts.interactions))+")"
		Form:C1466.sfw.entry.panel.pages[2].label:="Jobs & Deliveries ("+String:C10(Num:C11($counts.jobs))+")"
		Form:C1466.sfw.entry.panel.pages[3].label:="Documents ("+String:C10(Num:C11(Form:C1466.nb_sfw_Documents))+")"
	End use
	Form:C1466.sfw.drawHTab()

	//mark:-BTN 
Function btnOpenCustomer()
	$entity:=Form:C1466.current_item.customer
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "customer")
	
Function btnOpenStaff()
	$entity:=Form:C1466.current_item.staff
	Form:C1466.sfw.openInANewWindow($entity; "qualityAssurance"; "staff")
	
Function btnCreateCustomer()
	Form:C1466.sfw.openCreateWindow("customerService"; "customer")
	
Function btnDatePickerCreate($object; $attribut; $stmp; $minMax)
	var $currentDate : Date
	
	If (Form:C1466.sfw.checkIsInModification())
		$name:=OBJECT Get name:C1087
		OBJECT GET COORDINATES:C663(*; $name; $x1; $y1; $x2; $y2)
		CONVERT COORDINATES:C1365($x1; $y1; XY Current form:K27:5; XY Current window:K27:6)
		
		$currentDate:=Current date:C33()
		Case of 
			: (Num:C11($minMax)=1)
				DatePicker SET DEFAULT MAX DATE(!2040-01-01!)
				DatePicker SET DEFAULT MIN DATE($currentDate)
				
			: (Num:C11($minMax)=2)
				DatePicker SET DEFAULT MIN DATE(!2004-01-01!)
				DatePicker SET DEFAULT MAX DATE($currentDate)
				
		End case 
		
		
		$test:=cs:C1710.ga_datePicker.me.pick($object[$attribut]; OBJECT Get name:C1087(Object current:K67:2))  // the app's calendar
		If ($test#!00-00-00!)
			If (Bool:C1537($stmp))
				$object[$attribut]:=cs:C1710.sfw_stmp.me.build($test)
			Else 
				$object[$attribut]:=$test
			End if 
		End if 
	End if 
	
Function btnDatePickerClose()
	// the btnDatePickerClose button (its object method calls this too)
	If (Form:C1466.sfw.checkIsInModification())
		This:C1470.btnDatePicker(Form:C1466.current_item; "dateClose")
	End if
	
	
Function btnActionContacts()
	//mark: better code 
	$refMenu:=Create menu:C408()
	
	APPEND MENU ITEM:C411($refMenu; "Add main contact"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--addMainContact")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Add secondary contact"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--addSeconaryContact")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	// the selected secondary contact becomes the main one (ga_sales.makeMainContact)
	APPEND MENU ITEM:C411($refMenu; "Make main contact"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--makeMainContact")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.contact=Null:C1517) || (String:C10(Form:C1466.contact.type)#"Secondary")
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if

	APPEND MENU ITEM:C411($refMenu; "Delete contact"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--deleteContact")
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.contact=Null:C1517)
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if

	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	
	
	Case of 
		: ($choice="")
			
		: ($choice="--addMainContact")
			$uuids:=New collection:C1472()
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.mainContact#Null:C1517)
				$uuids.push(Form:C1466.current_item.moreData.mainContact.UUID)
			End if 
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.secondaryContacts#Null:C1517)
				$uuids:=$uuids.concat(Form:C1466.current_item.moreData.secondaryContacts)
			End if 
			
			$form:=New object:C1471()
			$form.lb_contacts:=ds:C1482.Contact.query("UUID_Company == :1 and not(UUID in :2)"; Form:C1466.current_item.UUID_Customer; $uuids)
			$ref:=Open form window:C675("Lead_chooseMainContact"; Sheet form window:K39:12)
			DIALOG:C40("Lead_chooseMainContact"; $form)
			CLOSE WINDOW:C154($ref)
			
			If (ok=1)
				If (Form:C1466.current_item.moreData=Null:C1517)
					Form:C1466.current_item.moreData:=New object:C1471()
				End if 
				
				If (Form:C1466.current_item.moreData.mainContact=Null:C1517)
					Form:C1466.current_item.moreData.mainContact:=New object:C1471()
				End if 
				
				Form:C1466.current_item.moreData.mainContact:={UUID: $form.current_contact.UUID}
				This:C1470.loadContacts()
				cs:C1710.panel_lead.me._activate_save_cancel_button()
			End if 
			
		: ($choice="--addSeconaryContact")
			$uuids:=New collection:C1472()
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.mainContact#Null:C1517)
				$uuids.push(Form:C1466.current_item.moreData.mainContact.UUID)
			End if 
			If (Form:C1466.current_item.moreData#Null:C1517) && (Form:C1466.current_item.moreData.secondaryContacts#Null:C1517)
				$uuids:=$uuids.concat(Form:C1466.current_item.moreData.secondaryContacts)
			End if 
			
			$form:=New object:C1471()
			$form.lb_contacts:=ds:C1482.Contact.query("UUID_Company == :1 and not(UUID in :2)"; Form:C1466.current_item.UUID_Customer; $uuids).toCollection()
			For each ($contact; $form.lb_contacts)
				$contact.selected:=False:C215
			End for each 
			
			$ref:=Open form window:C675("Lead_chooseSecondaryContacts"; Sheet form window:K39:12)
			DIALOG:C40("Lead_chooseSecondaryContacts"; $form)
			CLOSE WINDOW:C154($ref)
			
			If (ok=1)
				If (Form:C1466.current_item.moreData=Null:C1517)
					Form:C1466.current_item.moreData:=New object:C1471()
				End if 
				
				If (Form:C1466.current_item.moreData.secondaryContacts=Null:C1517)
					Form:C1466.current_item.moreData.secondaryContacts:=New collection:C1472()
				End if 
				
				For each ($contact; $form.lb_contacts)
					If ($contact.selected)
						Form:C1466.current_item.moreData.secondaryContacts.push($contact.UUID)
					End if 
				End for each 
				
				This:C1470.loadContacts()
				cs:C1710.panel_lead.me._activate_save_cancel_button()
			End if 

		: ($choice="--makeMainContact")
			If (cs:C1710.ga_sales.me.makeMainContact(Form:C1466.current_item; Form:C1466.contact.UUID))
				Form:C1466.contact:=Null:C1517
				This:C1470.loadContacts()
				cs:C1710.panel_lead.me._activate_save_cancel_button()
			End if

		: ($choice="--deleteContact")

			Case of
				: (Form:C1466.current_item.moreData=Null:C1517)
				: (Form:C1466.contact.type="Main")
					Form:C1466.current_item.moreData.mainContact:=Null:C1517
				: (Form:C1466.current_item.moreData.secondaryContacts#Null:C1517)
					$index:=Form:C1466.current_item.moreData.secondaryContacts.indexOf(Form:C1466.contact.UUID)
					If ($index#-1)  // tested $indexOf, a variable never set
						Form:C1466.current_item.moreData.secondaryContacts.remove($index)
					End if
			End case
			Form:C1466.contact:=Null:C1517
			This:C1470.loadContacts()
			cs:C1710.panel_lead.me._activate_save_cancel_button()
	End case 
	
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
	
	
Function bActionInteractions()
	// the menu and its actions (schedule, log, complete, cancel): ga_followUps, shared with the
	// quote's Follow-ups tab. The list is read again: it may hold the quote's follow-ups too
	If (cs:C1710.ga_followUps.me.actionMenu(Form:C1466.current_item; Form:C1466.current_interaction; Form:C1466.sfw.checkIsInModification()))
		This:C1470.loadInteractions()
		cs:C1710.panel_lead.me._activate_save_cancel_button()
	End if 
	This:C1470._countInteractions()  // the Interactions tab label (redrawn on the bound variable change)

Function pup_interaction($type; $currentUUID)->$uuid : Text
	If (Form:C1466.sfw.checkIsInModification=Null:C1517) || (Form:C1466.sfw.checkIsInModification#Null:C1517 && Form:C1466.sfw.checkIsInModification())
		$displayMenu:=True:C214
		Case of 
			: ($type="method")
				$dc:="InteractionMethod"
				$cacheAttribut:="interactionMethod"
				$widgetName:="pup_method"
				
			: ($type="outcome")
				$dc:="InteractionOutcome"
				$cacheAttribut:="interactionOutcome"
				$widgetName:="pup_outcome"
				
			: ($type="trigger")
				$dc:="InteractionTrigger"
				$cacheAttribut:="interactionTrigger"
				$widgetName:="pup_trigger"
				
			: ($type="type")
				$dc:="InteractionType"
				$cacheAttribut:="interactionType"
				$widgetName:="pup_type"
				
				If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheAttribut]=Null:C1517)
					ds:C1482[$dc].cacheLoad()
				End if 
				$items:=Storage:C1525.cache[$cacheAttribut].query("UUID == :1"; $currentUUID)
				If ($items.length#0)
					$displayMenu:=$items[0].code#"COMPLETED"
				End if 
				
				
				
		End case 
		
		If ($displayMenu)
			$menu:=Create menu:C408
			If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheAttribut]=Null:C1517)
				ds:C1482[$dc].cacheLoad()
			End if 
			
			For each ($eItem; Storage:C1525.cache[$cacheAttribut])
				APPEND MENU ITEM:C411($menu; $eItem.name; *)
				SET MENU ITEM PARAMETER:C1004($menu; -1; $eItem.UUID)
				If ($eItem.UUID=$currentUUID)
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					If (Is Windows:C1573)
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
					End if 
				End if 
			End for each 
			$uuid:=Dynamic pop up menu:C1006($menu)
			RELEASE MENU:C978($menu)
			
			Case of 
				: ($uuid#"")
					$item:=Storage:C1525.cache[$cacheAttribut].query("UUID == :1"; $uuid)[0]
					OBJECT SET TITLE:C194(*; $widgetName; $item.name)
			End case 
		End if 
		
	End if 
	
Function pup_filter($filterType : Text)
	$attr:=$filterType#"status" ? $filterType : "type"
	$capitalizeType:=cs:C1710.sfw_string.me.stringCapitalize($attr)
	$cacheAttribut:="interaction"+$capitalizeType
	$dc:="Interaction"+$capitalizeType
	$label:=""
	$allItems:=$filterType="status" ? "All statuses" : "All "+$filterType+"s"
	If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache[$cacheAttribut]=Null:C1517)
		ds:C1482[$dc].cacheLoad()
	End if 
	
	$menu:=Create menu:C408
	
	APPEND MENU ITEM:C411($menu; $allItems; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "all")
	If (Form:C1466.interactons_filters[$filterType].length=0)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		If (Is Windows:C1573)
			SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
		End if 
	End if 
	
	APPEND MENU ITEM:C411($menu; "-")
	
	For each ($item; Storage:C1525.cache[$cacheAttribut])
		APPEND MENU ITEM:C411($menu; $item.name; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $item.UUID+"_"+$item.name)
		If (Form:C1466.interactons_filters[$filterType].indexOf($item.UUID)#-1)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
	End for each 
	
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	
	
	Case of
		: ($choice="")
		: ($choice="all")
			Form:C1466.interactons_filters[$filterType].clear()
		Else
			$items:=Split string:C1554($choice; "_")
			$uuid:=$items[0]  // a UUID has no "_"; the name after it is not used (names can hold one)

			$index:=Form:C1466.interactons_filters[$filterType].indexOf($uuid)
			If ($index#-1)
				Form:C1466.interactons_filters[$filterType].remove($index)
			Else
				Form:C1466.interactons_filters[$filterType].push($uuid)
			End if
	End case
	This:C1470._drawFilterTitle($filterType)

Function _drawFilterTitle($filterType : Text)
	// the title of a filter button of the Interactions page: "All statuses" / "All triggers", the
	// name of the one value picked, or "2 statuses" / "3 triggers"
	var $selected : Collection
	var $plural; $dc : Text
	$plural:=($filterType="status") ? "statuses" : $filterType+"s"
	$dc:="Interaction"+cs:C1710.sfw_string.me.stringCapitalize(($filterType#"status") ? $filterType : "type")
	$selected:=(Form:C1466.interactons_filters=Null:C1517) ? New collection:C1472 : (Form:C1466.interactons_filters[$filterType] || New collection:C1472)
	Case of
		: ($selected.length=0)
			OBJECT SET TITLE:C194(*; "pupFilter_"+$filterType; "All "+$plural)
		: ($selected.length=1)
			OBJECT SET TITLE:C194(*; "pupFilter_"+$filterType; String:C10(ds:C1482[$dc].get($selected[0]).name))
		Else
			OBJECT SET TITLE:C194(*; "pupFilter_"+$filterType; String:C10($selected.length)+" "+$plural)
	End case
	
	
	
Function selectCustomer()
	var $previousCustomer : Text
	
	If (Form:C1466.sfw.checkIsInModification())
		$previousCustomer:=Form:C1466.current_item.UUID_Customer
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorCustomers"; "customer")
		$selector.setTitle("Choose a Customer")
		$selector.setCurrentItem(Form:C1466.current_item.customer)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						Form:C1466.current_item.UUID_Customer:=$itemSeleted.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer)=True:C214)
							Form:C1466.current_item.UUID_Customer:=16*"00"
						End if 
				End case 
				This:C1470._clearInfoAfterChangingCustomer($previousCustomer)
				This:C1470.drawPup_customer()
				Form:C1466.current_item.deal:=True:C214
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Customer:=16*"00"
				This:C1470._clearInfoAfterChangingCustomer($previousCustomer)
			: ($selector.needCreation())
				$selector.createANewEntity("cs.panel_lead.me.callbackAfterCreationCustomer($1)")
				Form:C1466.current_item.deal:=False:C215
		End case 
	End if 
	
	
Function callbackAfterCreationCustomer($key : Text)
	var $previousCustomer : Text
	$previousCustomer:=Form:C1466.current_item.UUID_Customer
	Form:C1466.current_item.UUID_Customer:=$key
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Customer)=True:C214)
		Form:C1466.current_item.UUID_Customer:=16*"00"
	End if
	// the contacts, quote, PO and job are cleared in the panel (this callback comes from the main window)
	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_lead.me._clearInfoAfterChangingCustomer($1)); *; $previousCustomer)
	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_lead.me.drawPup_customer()); *)
	

//Mark:- Dynamic-rendering mirrors of the form object methods
// activateDocument() on the Leads entry adds the framework Documents page, which switches the
// panel to dynamic-source rendering: every object method of the form is replaced by
// sfw_dynamicForm_script, which calls cs.panel_lead.me[objectName]() - and does nothing, without
// an error, when there is no function of that name. Each function below is named after a form
// object; the object method calls it too, so both modes run the same code. Objects whose
// function already exists above: bActionInteractions, btnDatePicker (no parameter),
// btnDatePickerClose, pup_nextStep, pup_priority, pup_serviceType, pup_stage.

Function bActionQuoteLines()
	This:C1470.btnActionContacts()
	
Function btnDatePickerCreate1()
	This:C1470._pickInteractionDate("creationDate")

Function btnDatePickerCreate2()
	This:C1470._pickInteractionDate("followUPDate")

Function _pickInteractionDate($attribute : Text)
	// an interaction date from the calendar, saved at once like the other detail fields (the lead's
	// afterSave reads the interactions back from the data file, so an unsaved date was lost)
	If (FORM Event:C1606.code=On Clicked:K2:4) && (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.current_interaction#Null:C1517)
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_interaction; $attribute))
			This:C1470._saveCurrentInteraction()
		End if
	End if

Function entryField_Inter_input_creationDate()
	This:C1470._saveCurrentInteraction()

Function entryField_Inter_input_followUPDate()
	This:C1470._saveCurrentInteraction()

Function _saveCurrentInteraction()
	// a detail field of the selected interaction changed (typed date, calendar): saved at once,
	// inside the lead's Modify, so the lead's Cancel still undoes it
	var $info : Object
	If (Form:C1466.current_interaction#Null:C1517) && ((FORM Event:C1606.code=On Data Change:K2:15) || (FORM Event:C1606.code=On Clicked:K2:4))
		$info:=Form:C1466.current_interaction.save()
		If ($info.success)
			This:C1470._activate_save_cancel_button()
		End if
	End if
	
Function btnForward()
	This:C1470.btnOpenCustomer()
	
Function btnForward2()
	This:C1470.btnOpenStaff()
	
Function entryField_Inter_input_notes1()
	var $result : Object
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			$result:=Form:C1466.current_interaction.save()
			If ($result.success)
				This:C1470._activate_save_cancel_button()
			Else 
				cs:C1710.sfw_dialog.me.alert("The interaction could not be saved.")
			End if 
	End case 
	
Function entryField_probabilityPC()
	// a percentage: kept between 0 and 100
	Case of
		: (Form:C1466.current_item.probabilityPC>100)
			Form:C1466.current_item.probabilityPC:=100
		: (Form:C1466.current_item.probabilityPC<0)
			Form:C1466.current_item.probabilityPC:=0
	End case
	
Function lb_interactions()
	Case of 
		: (FORM Event:C1606.code=On Selection Change:K2:29)
			// reassigned so the detail inputs bound to Form.current_interaction (number, creation and
			// follow-up dates, notes) are redrawn: they stayed empty while the pop-ups, drawn by code,
			// showed the selected interaction
			Form:C1466.current_interaction:=Form:C1466.current_interaction
			This:C1470.drawPup_Interaction(["method"; "outcome"; "trigger"; "sales"; "contact"; "type"])
			This:C1470.display_interactionDetails()
	End case 
	
Function pup_contact()
	var $contact : Object
	var $menu; $choice : Text
	var $items : Collection
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		For each ($contact; Form:C1466.current_item.contacts())
			APPEND MENU ITEM:C411($menu; $contact.fullName+" - "+$contact.type; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $contact.UUID+"_"+$contact.fullName+" - "+$contact.type)
			If (Form:C1466.current_interaction#Null:C1517) && ($contact.UUID=Form:C1466.current_interaction.UUID_Contact)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choice:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		If ($choice#"")
			$items:=Split string:C1554($choice; "_")
			Form:C1466.current_interaction.UUID_Contact:=$items[0]
			Form:C1466.current_interaction.save()
			This:C1470._activate_save_cancel_button()
			OBJECT SET TITLE:C194(*; "pup_contact"; $items[1])
		End if 
	End if 
	
Function pup_customer()
	This:C1470.selectCustomer()
	
Function pup_job()
	This:C1470.selectJob()
	
Function pup_method()
	This:C1470._pickInteractionValue("method"; "UUID_Method")
	
Function pupJobs_timing()
	This:C1470._pickJobsFilter("timing")

Function pupJobs_period()
	This:C1470._pickJobsFilter("period")

Function pup_outcome()
	This:C1470._pickInteractionValue("outcome"; "UUID_Outcome")
	
Function pup_po()
	This:C1470.selectPO()
	
Function pup_quote()
	This:C1470.selectQuote()
	
Function pup_sales()
	var $staff : Object
	var $menu; $choice : Text
	var $items : Collection
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		// the staff with the Sales profile (Staff.salesPeople), as in the Log interaction and Schedule follow-up
		// dialogs (Staff has no department link: the query on department.name found nobody)
		For each ($staff; ds:C1482.Staff.salesPeople())
			APPEND MENU ITEM:C411($menu; $staff.fullName; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $staff.UUID)
			If (Form:C1466.current_interaction#Null:C1517) && ($staff.UUID=Form:C1466.current_interaction.UUID_Staff)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choice:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		If ($choice#"")
			// the parameter is the UUID alone: splitting "UUID-name" on "-" cut names with a "-"
			Form:C1466.current_interaction.UUID_Staff:=$choice
			OBJECT SET TITLE:C194(*; "pup_sales"; String:C10(ds:C1482.Staff.get($choice).fullName))
			Form:C1466.current_interaction.save()
			This:C1470._activate_save_cancel_button()
		End if 
	End if 
	
Function pup_staff()
	This:C1470.selectStaff()
	
Function pup_trigger()
	This:C1470._pickInteractionValue("trigger"; "UUID_Trigger")
	
Function pup_type()
	This:C1470._pickInteractionValue("type"; "UUID_Type")
	
Function pupFilter_status()
	This:C1470.pup_filter("status")
	This:C1470.loadInteractions()
	
Function pupFilter_trigger()
	This:C1470.pup_filter("trigger")
	This:C1470.loadInteractions()
	
// pup_method / pup_outcome / pup_trigger / pup_type: pick a value for the current interaction
Function _pickInteractionValue($type : Text; $attribute : Text)
	var $uuid : Text
	$uuid:=This:C1470.pup_interaction($type; Form:C1466.current_interaction[$attribute])
	If ($uuid#"")
		Form:C1466.current_interaction[$attribute]:=$uuid
		Form:C1466.current_interaction.save()
		This:C1470._activate_save_cancel_button()
	End if 
	
