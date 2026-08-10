//%attributes = {}



/*
Method Name : _ga_printSpecList
Author : Medard /4D PS
Date : 03-July-2025
Purpose : Print Specs  View List
*/

If (Form:C1466.sfw.lb_items.length>0)
	
	var $identEntry : Text:=Form:C1466.sfw.view.ident
	var $context : Object
	
	$context:=New object:C1471()
	
	var ListTypes : Collection:=New collection:C1472(True:C214; False:C215)
	
	For each ($onlyForms; ListTypes)
		$printType:=$onlyForms ? "Form" : "Spec"
		
		$context.length:=Form:C1466.sfw.lb_items.query("isForm =:1 & suppress =:2"; $onlyForms; False:C215).length
		
		If ($context.length>0)
			$OK:=cs:C1710.sfw_dialog.me.confirm("Print "+$printType+" Index?"; "yes"; "no")
			
			$continue:=(Form:C1466.sfw.lb_items.query("isForm =:1 & suppress =:2"; $onlyForms; False:C215).length>0)
			
			If ($continue) & ($OK)
				
				If ($onlyForms=False:C215)
					$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/specsListPrint.4wp")
				Else 
					$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/specsFormListPrint.4wp")
				End if 
				
				$template:=WP Import document:C1318($file.platformPath)
				
				
				$context.controlDept:=_ga_getListFiltersValues("ControllingDepartment"; "UUID")
				$context.documentType:=_ga_getListFiltersValues("DocumentCategory"; "UUID")
				If ($onlyForms=False:C215)
					$context.footerLeft:="Form# MSI-QA-01-Rev A"  //Specs
				Else 
					$context.footerLeft:="Form# MSI-QA-02-Rev A"  //Forms
				End if 
				$context.user:=Current machine:C483
				
				SET PRINT OPTION:C733(Orientation option:K47:2; 1)
				
				Case of 
					: ($identEntry="main")
						If ($onlyForms=False:C215)
							$context.subject:="Specifications"
						Else 
							$context.subject:="Forms"
						End if 
						
					: ($identEntry="docsRequiringReviewSoon")
						
						If ($onlyForms=False:C215)
							$context.subject:="Specifications late in reviewing "
						Else 
							$context.subject:="Forms late in reviewing"
						End if 
						
					: ($identEntry="OnlySpecs")
						
						$context.subject:="Specs"
						
					: ($identEntry="OnlyForms")
						
						$context.subject:="Forms"
					Else 
						
						$context.subject:="Specifications"
						
				End case 
				
				
				WP SET DATA CONTEXT:C1786($template; $context)
				
				PRINT SETTINGS:C106(2)
				WP PRINT:C1343($template)
				
			End if 
			
			
		End if 
		
	End for each 
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "No items in the list to print"))
	
End if 