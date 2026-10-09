//%attributes = {}
// Purpose: Print Specs / Forms index for the active Document Control view.
// modified by 4D/PS [2026-october-05]


If (Form:C1466.sfw=Null:C1517) | (Form:C1466.sfw.lb_items=Null:C1517) | (Form:C1466.sfw.lb_items.length=0)
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "No items in the list to print"))
	return 
End if 

var $identEntry : Text
If (Form:C1466.sfw.view#Null:C1517)
	$identEntry:=Form:C1466.sfw.view.ident
Else 
	$identEntry:=""
End if
var $context : Object

$context:=New object:C1471()

var ListTypes : Collection:=New collection:C1472(True:C214; False:C215)

For each ($onlyForms; ListTypes)
	$printType:=$onlyForms ? "Form" : "Spec"
	
	$context.length:=Form:C1466.sfw.lb_items.query("isForm =:1 & suppress =:2"; $onlyForms; False:C215).length
	
	If ($context.length>0)
		$OK:=cs:C1710.sfw_dialog.me.confirm("Print "+$printType+" Index?"; "yes"; "no")
		
		If ($OK)
			
			If ($onlyForms=False:C215)
				$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/specsListPrint.4wp")
			Else 
				$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/specsFormListPrint.4wp")
			End if 
			
			If (Not:C34($file.exists))
				cs:C1710.sfw_dialog.me.alert("The "+$printType+" index print template is missing.")
			Else 
				
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
						
					: ($identEntry="docsLateInReviewing")
						If ($onlyForms=False:C215)
							$context.subject:="Specifications late in reviewing"
						Else 
							$context.subject:="Forms late in reviewing"
						End if 
						
					: ($identEntry="docsRequiringReviewSoon")
						If ($onlyForms=False:C215)
							$context.subject:="Specifications requiring review soon"
						Else 
							$context.subject:="Forms requiring review soon"
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
				If (OK=1)
					WP PRINT:C1343($template)
				End if 
				
			End if 
			
		End if 
		
		
	End if 
	
End for each 
