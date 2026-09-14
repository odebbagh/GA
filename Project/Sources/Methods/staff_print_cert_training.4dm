//%attributes = {}

// Purpose: Print certification training for the current Staff — WP template CERT_TRAINING via sfw_DocumentModel (same pattern as _ga_printReceivingTag / RECV_TAG). Legacy print-form path kept disabled.
// Parameters: Form.current_item — Staff entity (panel_staff).
// modified by 4D/PS [2026-may-12]

If (Form:C1466.current_item#Null:C1517)
	
	If (True:C214)
		
		var $assign : cs:C1710.CertificationAssignmentEntity
		var $context : Object
		var $template : Object
		var $model : cs:C1710.sfw_DocumentModelEntity
		var $certRow : Object
		
		// Purpose: CERT_TRAINING document model — WP SET DATA CONTEXT then WP PRINT (aligned with RECV_TAG implementation).
		// modified by 4D/PS [2026-may-12]
		
		$context:=New object:C1471()
		$template:=WP New:C1317()
		
		$model:=ds:C1482.sfw_DocumentModel.query("name =:1"; "CERT_TRAINING").first()
		If ($model#Null:C1517)
			$template:=$model.area
		Else 
			// Purpose: Fail fast when the WP template is missing instead of printing a blank document.
			// modified by 4D/PS [2026-may-21]
			cs:C1710.sfw_dialog.me.alert("Document model \"\"CERT_TRAINING\"\" was not found. Import or create it in Administration before printing.")
			
		End if 
		
		$division:=ds:C1482.Division.query("UUID =:1"; Form:C1466.current_item.UUID_Division)
		$divisionName:=$division.length>0 ? $division[0].name : ""
		
		$memberships:=ds:C1482.Membership.query("UUID_Staff= :1"; Form:C1466.current_item.UUID)
		If ($memberships.length>0)
			$department:=$memberships[0].team
			If ($department#Null:C1517)
				$departmentName:=$department.name
			Else 
				$departmentName:=""
			End if 
		Else 
			$departmentName:=""
		End if 
		
		
		$context.employee:=New object:C1471(\
			"lastName"; Form:C1466.current_item.lastName; \
			"firstName"; Form:C1466.current_item.firstName; \
			"department"; $departmentName; \
			"division"; $divisionName; \
			"code"; Form:C1466.current_item.code; \
			"shift"; Form:C1466.current_item.shift; \
			"retrainDate"; Form:C1466.current_item.retrainDate\
			)
		
		// Purpose: Feed the WP repeating sections — valid vs expired certifications mirror the legacy
		// cert_training / other_traning print-form bands (validityActive vs finite expired assignments).
		// modified by 4D/PS [2026-may-21]
		$context.validCertifications:=New collection:C1472()
		$context.expiredCertifications:=New collection:C1472()
		
		For each ($assign; Form:C1466.current_item.assignments)
			If ($assign.validityActive) && ($assign.certification#Null:C1517)
				$certRow:=New object:C1471("name"; $assign.certification.name; "date"; $assign.certificationDate)
				$context.validCertifications.push($certRow)
			End if 
		End for each 
		
		For each ($assign; Form:C1466.current_item.assignments)
			If (($assign.expiredIn>0) && Not:C34($assign.validityActive) && ($assign.certification#Null:C1517))
				$certRow:=New object:C1471("name"; $assign.certification.name; "date"; $assign.certificationDate)
				$context.expiredCertifications.push($certRow)
			End if 
		End for each 
		
		WP SET DATA CONTEXT:C1786($template; $context)
		
		PRINT SETTINGS:C106(2)
		WP PRINT:C1343($template)
		
	Else 
		// Legacy: structured print forms [Staff] cert_training / other_traning — disable top branch (If(False)) and set this If(True) to restore.
		// modified by 4D/PS [2026-may-12]
		
		
		var $form : Object
		
		QUERY:C277([Staff:135]; [Staff:135]UUID:1=Form:C1466.current_item.UUID)
		
		//FORM SET OUTPUT([Staff]; "cert_training")
		//PRINT RECORD([Staff])
		
		PRINT SETTINGS:C106()
		
		OPEN PRINTING JOB:C995
		
		$form:=New object:C1471()
		
		$form.employee:=New object:C1471(\
			"lastName"; [Staff:135]lastName:5; \
			"firstName"; [Staff:135]firstName:4; \
			"department"; [Staff:135]moreData:11; \
			"division"; [Staff:135]UUID_Division:14; \
			"code"; [Staff:135]code:10; \
			"retrainingDate"; [Staff:135]stmpRetrain:3\
			)
		
		Print form:C5([Staff:135]; "cert_training"; $form; Form header:K43:3)
		
		// Purpose: Valid trainings — expiredIn is duration days; filter uses computed validityActive, not expiredIn versus now().
		// modified by 4D/PS [2026-may-12]
		For each ($assign; Form:C1466.current_item.assignments)
			If ($assign.validityActive)
				
				$form:=New object:C1471()
				
				$form.certification:=New object:C1471(\
					"name"; $assign.certification.name; \
					"date"; $assign.certificationDate\
					)
				Print form:C5([Staff:135]; "cert_training"; $form; Form detail:K43:1)
				Print form:C5([Staff:135]; "cert_training"; $form; Form break0:K43:14)
				
			End if 
		End for each 
		
		Print form:C5([Staff:135]; "other_traning"; Form header:K43:3)
		
		// Purpose: Expired trainings — finite duration rows whose validity window ended before today.
		// modified by 4D/PS [2026-may-12]
		For each ($assign; Form:C1466.current_item.assignments)
			If (($assign.expiredIn>0) && Not:C34($assign.validityActive))
				
				$form:=New object:C1471()
				
				$form.certification:=New object:C1471(\
					"name"; $assign.certification.name; \
					"date"; $assign.certificationDate\
					)
				Print form:C5([Staff:135]; "cert_training"; $form; Form detail:K43:1)
				Print form:C5([Staff:135]; "cert_training"; $form; Form break0:K43:14)
				
			End if 
		End for each 
		
		
		Print form:C5([Staff:135]; "cert_training"; $form; Form footer:K43:2)
		
		CLOSE PRINTING JOB:C996
		
	End if 
	
End if 
