singleton Class constructor
	// It's a singleton class
	
Function formMethod()
	If (Undefined:C82(Form:C1466.lb_items) | (Form:C1466.lb_items=Null:C1517))
		Form:C1466.lb_items:=New collection:C1472()
	End if 
	If (Undefined:C82(Form:C1466.lb_processDocs) | (Form:C1466.lb_processDocs=Null:C1517))
		Form:C1466.lb_processDocs:=New collection:C1472()
	End if 
	
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadSteps()
		This:C1470.loadProcessDocs()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		This:C1470.loadSteps()
		This:C1470.loadProcessDocs()
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
Function redrawAndSetVisible()
	Use (Form:C1466.sfw.entry.panel.pages)
		If (Form:C1466.sfw.entry.panel.pages.length>0)
			Form:C1466.sfw.entry.panel.pages[0].label:="Steps ("+String:C10(Form:C1466.lb_items.length)+")"
		End if 
		If (Form:C1466.sfw.entry.panel.pages.length>1)
			Form:C1466.sfw.entry.panel.pages[1].label:="Forms & Specs ("+String:C10(Form:C1466.lb_processDocs.length)+")"
		End if 
	End use 
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	$offset_r:=5
	Case of 
		: (FORM Get current page:C276(*)=1)
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_items"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_items"; $left_lb; $top_lb; $widthSubform-$offset_r; $heightSubform-$offset)
	
		: (FORM Get current page:C276(*)=2)
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_3"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_processDocs"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_3"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_processDocs"; $left_lb; $top_lb; $widthSubform-$offset_r; $heightSubform-$offset)
	End case 
	
Function loadSteps()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_items:=ds:C1482.Step.query("UUID_StepProcess = :1"; Form:C1466.current_item.UUID).orderBy("description")
	Else 
		Form:C1466.lb_items:=New collection:C1472()
	End if 
	
	
// ----------------------------------------------
// Forms & Specs page
// Shows every spec and GAF form linked to at least one step of this process, with how many
// of the process steps carry it, and adds or removes one on all the steps at once. There is
// no process-level storage: each action writes the per-step links (StepSpecification), the
// same records Step Templates edits one step at a time. The writes happen inside the
// entry's transaction, so Cancel undoes them.
// ----------------------------------------------
Function loadProcessDocs()
	var $steps : 4D:C1709.EntitySelection
	var $link : 4D:C1709.Entity
	var $rows : Object
	var $row : Object
	var $key : Text
	var $nbSteps : Integer
	
	Form:C1466.lb_processDocs:=New collection:C1472()
	Form:C1466.selectedProcessDoc:=Null:C1517
	Form:C1466.processStepCount:=0
	If (Form:C1466.current_item=Null:C1517)
		return
	End if 
	
	$steps:=ds:C1482.Step.query("UUID_StepProcess = :1"; Form:C1466.current_item.UUID)
	$nbSteps:=$steps.length
	Form:C1466.processStepCount:=$nbSteps
	If ($nbSteps=0)
		return
	End if 
	
	$rows:=New object:C1471
	For each ($link; ds:C1482.StepSpecification.query("UUID_Step IN :1"; $steps.distinct("UUID")))
		If ($link.specification#Null:C1517)
			$row:=$rows[$link.UUID_Specification]
			If ($row=Null:C1517)
				$row:=New object:C1471(\
					"UUID_Specification"; $link.UUID_Specification; \
					"isForm"; Bool:C1537($link.specification.isForm); \
					"type"; Choose:C955(Bool:C1537($link.specification.isForm); "Form"; "Spec"); \
					"spec"; $link.specification.spec; \
					"revision"; $link.specification.revision; \
					"title"; $link.specification.title; \
					"stepUUIDs"; New collection:C1472)
				$rows[$link.UUID_Specification]:=$row
			End if 
			If ($row.stepUUIDs.indexOf($link.UUID_Step)<0)
				$row.stepUUIDs.push($link.UUID_Step)
			End if 
		End if 
	End for each 
	
	For each ($key; $rows)
		$row:=$rows[$key]
		$row.onAllSteps:=($row.stepUUIDs.length=$nbSteps)
		$row.coverage:=String:C10($row.stepUUIDs.length)+" / "+String:C10($nbSteps)
		Form:C1466.lb_processDocs.push($row)
	End for each 
	Form:C1466.lb_processDocs:=Form:C1466.lb_processDocs.orderBy("isForm asc, spec asc")
	
	
Function bActionProcessDocs()
	var $refMenu : Text
	var $choose : Text
	var $form : Object
	var $winRef : Integer
	var $available : 4D:C1709.EntitySelection
	var $specRow : 4D:C1709.Entity
	var $lbVals : Collection
	var $fullUUIDs : Collection
	var $result : Object
	var $inModification : Boolean
	var $hasSelection : Boolean
	
	$inModification:=Form:C1466.sfw.checkIsInModification()
	$hasSelection:=(Form:C1466.selectedProcessDoc#Null:C1517)
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Add a spec or form to every step")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--add")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34($inModification)) | (Num:C11(Form:C1466.processStepCount)=0)
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Add the selected one to the remaining steps")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--complete")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/add.png")
	If (Not:C34($inModification)) | (Not:C34($hasSelection))
		DISABLE MENU ITEM:C150($refMenu; -1)
	Else 
		If (Bool:C1537(Form:C1466.selectedProcessDoc.onAllSteps))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Remove the selected one from every step")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--remove")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/image/button/delete.png")
	If (Not:C34($inModification)) | (Not:C34($hasSelection))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
		: ($choose="--add")
			// suppressed records are superseded revisions or obsolete documents: never offered.
			// One already on every step has nothing left to add; a partial one stays pickable.
			$fullUUIDs:=Form:C1466.lb_processDocs.query("onAllSteps = :1"; True:C214).extract("UUID_Specification")
			If ($fullUUIDs.length=0)
				$available:=ds:C1482.Specification.query("suppress = :1"; False:C215).orderBy("isForm asc, spec asc")
			Else 
				$available:=ds:C1482.Specification.query("suppress = :1 AND NOT(UUID IN :2)"; False:C215; $fullUUIDs).orderBy("isForm asc, spec asc")
			End if 
	
			$lbVals:=New collection:C1472()
			For each ($specRow; $available)
				$lbVals.push(New object:C1471(\
					"UUID"; $specRow.UUID; \
					"name"; $specRow.spec; \
					"description"; Choose:C955(Bool:C1537($specRow.isForm); "[Form] "; "[Spec] ")+$specRow.spec+" rev "+String:C10($specRow.revision)+"  "+$specRow.title\
					))
			End for each 
	
			$form:=New object:C1471(\
				"windowTitle"; "Add to every step of "+String:C10(Form:C1466.current_item.name); \
				"inputPlaceholder"; "Search by code or title ..."; \
				"lb_values"; $lbVals\
				)
	
			$winRef:=Open form window:C675("searchOnList_v2"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("searchOnList_v2"; $form)
			CLOSE WINDOW:C154($winRef)
	
			If ((OK=1) & ($form.selectedItem#Null:C1517))
				$result:=This:C1470._linkToAllSteps($form.selectedItem.UUID)
				This:C1470._afterBulkChange($result)
			End if 
	
		: ($choose="--complete")
			$result:=This:C1470._linkToAllSteps(Form:C1466.selectedProcessDoc.UUID_Specification)
			This:C1470._afterBulkChange($result)
	
		: ($choose="--remove")
			If (cs:C1710.sfw_dialog.me.confirm("Remove "+String:C10(Form:C1466.selectedProcessDoc.spec)+" from the "+String:C10(Form:C1466.selectedProcessDoc.stepUUIDs.length)+" step(s) of this process that carry it?"; "Remove"; "CANCEL"))
				$result:=This:C1470._unlinkFromAllSteps(Form:C1466.selectedProcessDoc.UUID_Specification)
				This:C1470._afterBulkChange($result)
			End if 
	End case 
	
	
// Links one Specification to every step of the current process that does not have it yet.
Function _linkToAllSteps($specUUID : Text)->$result : Object
	var $spec : 4D:C1709.Entity
	var $step : 4D:C1709.Entity
	var $link : 4D:C1709.Entity
	var $res : Object
	
	$result:=New object:C1471("changed"; 0; "failed"; New collection:C1472)
	$spec:=ds:C1482.Specification.get($specUUID)
	If ($spec=Null:C1517) | (Form:C1466.current_item=Null:C1517)
		return $result
	End if 
	
	For each ($step; ds:C1482.Step.query("UUID_StepProcess = :1"; Form:C1466.current_item.UUID))
		If (ds:C1482.StepSpecification.query("UUID_Step = :1 AND UUID_Specification = :2"; $step.UUID; $specUUID).length=0)
			$link:=ds:C1482.StepSpecification.new()
			$link.UUID_Step:=$step.UUID
			$link.UUID_Specification:=$specUUID
			// "manual" links survive a re-run of the GAF link import
			$link.moreData:=New object:C1471("source"; "manual")
			$res:=$link.save()
			If ($res.success)
				$result.changed+=1
				This:C1470._syncStep($step; $spec; $result)
			Else 
				$result.failed.push(String:C10($step.description))
			End if 
		End if 
	End for each 
	
	
// Removes one Specification from every step of the current process.
Function _unlinkFromAllSteps($specUUID : Text)->$result : Object
	var $spec : 4D:C1709.Entity
	var $link : 4D:C1709.Entity
	var $step : 4D:C1709.Entity
	var $steps : 4D:C1709.EntitySelection
	var $res : Object
	
	$result:=New object:C1471("changed"; 0; "failed"; New collection:C1472)
	$spec:=ds:C1482.Specification.get($specUUID)
	If (Form:C1466.current_item=Null:C1517)
		return $result
	End if 
	
	$steps:=ds:C1482.Step.query("UUID_StepProcess = :1"; Form:C1466.current_item.UUID)
	For each ($link; ds:C1482.StepSpecification.query("UUID_Step IN :1 AND UUID_Specification = :2"; $steps.distinct("UUID"); $specUUID))
		$step:=$link.step
		$res:=$link.drop()
		If ($res.success)
			$result.changed+=1
			If ($step#Null:C1517)
				This:C1470._syncStep($step; $spec; $result)
			End if 
		Else 
			If ($step=Null:C1517)
				$result.failed.push("?")
			Else 
				$result.failed.push(String:C10($step.description))
			End if 
		End if 
	End for each 
	
	
// A spec (not a form) also changes what the traveller prints for that step, so the step's
// own copy is brought in line and saved. A step open in modification elsewhere is locked:
// it keeps its link change and is reported, so it can be re-saved from Step Templates.
Function _syncStep($step : 4D:C1709.Entity; $spec : 4D:C1709.Entity; $result : Object)
	var $res : Object
	
	If ($spec=Null:C1517)
		return
	End if 
	If (Bool:C1537($spec.isForm))
		return
	End if 
	
	$step.syncSpecifications()
	$res:=$step.save()
	If (Not:C34($res.success))
		$result.failed.push(String:C10($step.description)+" (traveller list not updated: record in use)")
	End if 
	
	
Function _afterBulkChange($result : Object)
	This:C1470.loadProcessDocs()
	If ($result.changed>0)
		This:C1470._activate_save_cancel_button()
	End if 
	If ($result.failed.length>0)
		cs:C1710.sfw_dialog.me.alert("Not updated:\r"+$result.failed.join("\r"))
	End if 
	
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
