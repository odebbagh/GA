//%attributes = {"executedOnServer":true}


//create moreData.barcodeData on all tables


var $colors : Collection:=New collection:C1472("#3CB371"; "#FFFF00"; "#FF7F50"; "#1E90FF"; "#FF0000")

var $carriers; $status; $recordStatuscolors : Collection
$carriers:=New collection:C1472("GAC Driver"; "Fed-Ex Priority"; "fedex Std Overnight"; "fedex"; "fedex Ground"; "Customer Pickup"; "UPS 2nd Day"; "UPS Ground"; "UPS Next Day"; "DHL")
$status:=New collection:C1472("Active"; "Hold"; "Retired"; "Void")
$recordStatuscolors:=New collection:C1472("#32CD32"; "#1E90FF"; "#FF0000"; "#FFFF00")



//----> [SalesTax]
$salesTaxes:=New collection:C1472(\
New object:C1471("code"; "T_082"; "value"; "0.0825"); \
New object:C1471("code"; "T_092"; "value"; "0.0925"); \
New object:C1471("code"; "T5_187"; "value"; "5.1875"); \
New object:C1471("code"; "T7_250"; "value"; "7.25"); \
New object:C1471("code"; "T7_750"; "value"; "7.75"); \
New object:C1471("code"; "T8_250"; "value"; "8.25"); \
New object:C1471("code"; "T8_500"; "value"; "8.5"); \
New object:C1471("code"; "T9_125"; "value"; "9.125"); \
New object:C1471("code"; "T9_250"; "value"; "9.25"); \
New object:C1471("code"; "T9_375"; "value"; "9.375"); \
New object:C1471("code"; "T9_500"; "value"; "9.5"); \
New object:C1471("code"; "T10_250"; "value"; "10.25")\
)
TRUNCATE TABLE:C1051([SalesTax:72])
For ($i; 0; $salesTaxes.length-1)
	
	$salesTax:=ds:C1482.SalesTax.new()
	$salesTax.code:=$salesTaxes[$i].code
	$salesTax.rate:=$salesTaxes[$i].value
	$salesTax.save()
	
End for 


//----> [CustomerStatus]
TRUNCATE TABLE:C1051([CustomerStatus:130])
For ($i; 0; $status.length-1)
	
	$divisionInfo_eStatus:=ds:C1482.CustomerStatus.new()
	$divisionInfo_eStatus.levelID:=$i+1
	$divisionInfo_eStatus.name:=$status[$i]
	$divisionInfo_eStatus.color:=$recordStatuscolors[$i]
	$divisionInfo_eStatus.save()
	
End for 

//----> [CustomerCarrier]
TRUNCATE TABLE:C1051([CustomerCarrier:7])
For ($i; 0; $carriers.length-1)
	
	$divisionInfo_eCarrier:=ds:C1482.CustomerCarrier.new()
	$divisionInfo_eCarrier.levelID:=$i+1
	$divisionInfo_eCarrier.name:=$carriers[$i]
	$divisionInfo_eCarrier.color:=""
	$divisionInfo_eCarrier.save()
End for 


//---->[ControllingDepartment]
var $eControllingDept : cs:C1710.ControllingDepartmentEntity
var $SpecControllingDepts : Collection:=New collection:C1472("All"; "Accounting"; "Assembly"; "Beanch"; \
"Business Development"; "Customer"; "Electrical Test"; "EMS"; "ESD-LU"; "Facilities"; "FSO"; \
"Hardware"; "HR"; "IT"; "Planning"; "Product Assurance"; "Program Management"; "Purchasing"; "QA"; \
"Reliability"; "Test"; "Vendor")
TRUNCATE TABLE:C1051([ControllingDepartment:45])
For ($i; 0; $SpecControllingDepts.length-1)
	$eControllingDept:=ds:C1482.ControllingDepartment.new()
	$eControllingDept.levelID:=$i
	$eControllingDept.name:=$SpecControllingDepts[$i]
	$eControllingDept.save()
End for 


//----> [EquipementLocation]
var $eEquipmentLocation : cs:C1710.EquipmentLocationEntity
var $equipmentsLocations : Collection:=New collection:C1472("4TH OPTICAL"; "Burn-in"; "Eng'r"; \
"Engineering"; "Environmental"; "EOL"; "FACILITY"; "FOL"; "FOL for Profiler"; \
"FOL/RTC"; "Front of Line"; "Lab/ Vibration"; "Lab/Mechanical Shock"; \
"Lab/Milpitas"; "Marking"; "Pad"; "Solder"; "Solder Dip"; "Trim")
TRUNCATE TABLE:C1051([EquipmentLocation:19])
For ($i; 0; $equipmentsLocations.length-1)
	$eEquipmentLocation:=ds:C1482.EquipmentLocation.new()
	$eEquipmentLocation.levelID:=$i+1
	$eEquipmentLocation.name:=$equipmentsLocations[$i]
	$eEquipmentLocation.color:="#FFFFFF"
	$eEquipmentLocation.save()
End for 


//----> [Division]
var $eDivision : cs:C1710.DivisionEntity
var $divisions : Collection:=New collection:C1472("GAC")
TRUNCATE TABLE:C1051([Division:20])
For ($i; 0; $divisions.length-1)
	$eDivision:=ds:C1482.Division.new()
	$eDivision.levelID:=$i+1
	$eDivision.name:=$divisions[$i]
	$eDivision.color:="#FFFFFF"
	$eDivision.save()
End for 


//----> [CICategory]
var $eCipCategory : cs:C1710.CICategoryEntity
TRUNCATE TABLE:C1051([CICategory:33])
var $cipCategories : Collection:=New collection:C1472("Internal Risk Mitigation"; \
"External Risk Mitigation"; "Internal Opportunity"; "External Opportunity"; "NMCR Only"; \
"Resource Need"; "Change to QMS"; "Corrective Action"; "Training Need"; "NCR Only"; "Improve Process"; \
"SCAR"; "RMA-KPI"; "RMA-NonKPI"; "NCMR Only"; "Corrective Action and Training"; "Repair"; "Other")
For ($i; 0; $cipCategories.length-1)
	$eCipCategory:=ds:C1482.CICategory.new()
	$eCipCategory.levelID:=$i+1
	$eCipCategory.name:=$cipCategories[$i]
	$eCipCategory.color:="#FFFFFF"
	$eCipCategory.save()
End for 

//----> [YesNoQuestion]
var $eQuestion : cs:C1710.YesNoQuestionEntity
var $questions : Collection:=New collection:C1472("Yes"; "No"; "N/A")
TRUNCATE TABLE:C1051([YesNoQuestion:34])
For ($i; 0; $questions.length-1)
	$eQuestion:=ds:C1482.YesNoQuestion.new()
	$eQuestion.levelID:=$i+1
	$eQuestion.name:=$questions[$i]
	$eQuestion.color:="#FFFFFF"
	$eQuestion.save()
End for 

//----> [CIPriority]
var $ePriority : cs:C1710.CIPriorityEntity
var $cipPriorities : Collection:=New collection:C1472("Active"; "Monitor"; "Deferred"; "Complete"; "Canceled")
TRUNCATE TABLE:C1051([CIPriority:27])
For ($i; 0; $cipPriorities.length-1)
	$ePriority:=ds:C1482.CIPriority.new()
	$ePriority.levelID:=$i+1
	$ePriority.name:=$cipPriorities[$i]
	$ePriority.color:=$colors[$i]
	$ePriority.save()
End for 

//----> [CIOrigin]
var $eOrigin : cs:C1710.CIOriginEntity
var $cipOrigins : Collection:=New collection:C1472("NCR"; "NCMR"; "SWOT"; "Process Risk"; "Human Factors"; \
"Management Review"; "Internal Audit"; "Internal Issue"; "Customer Audit"; "CB Audit"; "Customer CAR"; \
"Complaint"; "Feedback"; "Supplier"; "RMA"; "KPI/Objective Performance"; "Regulatory"; "Process Improvement"; "Other")
TRUNCATE TABLE:C1051([CIOrigin:31])
For ($i; 0; $cipOrigins.length-1)
	$eOrigin:=ds:C1482.CIOrigin.new()
	$eOrigin.levelID:=$i+1
	$eOrigin.name:=$cipOrigins[$i]
	$eOrigin.color:="#FFFFFF"
	$eOrigin.save()
End for 


//----> [CIHumanFactor]
var $eHumanFactor : cs:C1710.CIHumanFactorEntity
var $cipHumanFactors : Collection:=New collection:C1472("Not CAR"; "Not Applicable"; "Fatigue"; \
"Lack of Concentration"; "Complacency"; "Lack of Knowledge"; "Distraction"; "Lack of Teamwork"; \
"Lack of Resources"; "Pressure"; "Lack of Assertiveness"; "Stress"; "Lack of Awareness"; \
"Negative Norms "; "Ergonomics"; "Equipment"; "Culture"; "Competence"; "Environmental"; \
"Feelings"; "Lack of personnel"; "Other")
TRUNCATE TABLE:C1051([CIHumanFactor:29])
For ($i; 0; $cipHumanFactors.length-1)
	$eHumanFactor:=ds:C1482.CIHumanFactor.new()
	$eHumanFactor.levelID:=$i+1
	$eHumanFactor.name:=$cipHumanFactors[$i]
	$eHumanFactor.color:="#FFFFFF"
	$eHumanFactor.save()
End for 


//----> [CIDisposition]
var $eDisposition : cs:C1710.CIDispositionEntity
var $cipDispositions : Collection:=New collection:C1472("N/A (Not NCP)"; "Awaiting Disp."; "Scrap"; "Rework"; "Notified the customer"; \
"Repair"; "Use As Is"; "Return To Vendor"; "Improve methods"; "Increase Inventory"; "Revise Spec, Training"; "Revise Procedure"; "Other")
TRUNCATE TABLE:C1051([CIDisposition:28])
For ($i; 0; $cipDispositions.length-1)
	$eDisposition:=ds:C1482.CIDisposition.new()
	$eDisposition.levelID:=$i+1
	$eDisposition.name:=$cipDispositions[$i]
	$eDisposition.color:="#FFFFFF"
	$eDisposition.save()
End for 


//----> [Units]
var $eUnit : cs:C1710.UnitsEntity
var $units : Collection:=New collection:C1472("Bag"; "Can"; "EA"; "Hour"; "Lot"; "Pcs"; "Roll"; "Set"; "Box"; "Spool"; "Gallon"; "Ream"; "Case"; \
"Pack"; "Yesr"; "Lbs"; "Pair")
TRUNCATE TABLE:C1051([Units:49])
For ($i; 0; $units.length-1)
	$eUnit:=ds:C1482.Units.new()
	$eUnit.levelID:=$i+1
	$eUnit.name:=$units[$i]
	$eUnit.color:="#FFFFFF"
	$eUnit.save()
End for 


var $eDocCategory : cs:C1710.DocumentCategoryEntity
var $docCategories : Collection:=New collection:C1472("Internal- Procedure"; "Form. External Specifications"; "Military Standard"; "Industry Standards")
TRUNCATE TABLE:C1051([DocumentCategory:42])
For ($i; 0; $docCategories.length-1)
	$eDocCategory:=ds:C1482.DocumentCategory.new()
	$eDocCategory.levelID:=$i+1
	$eDocCategory.name:=$docCategories[$i]
	$eDocCategory.color:="#FFFFFF"
	$eDocCategory.save()
End for 

//----> [AuditStatus]
var $eAuditStatus : cs:C1710.AuditStatusEntity
var $auditStatus : Collection:=New collection:C1472("C - Conforming"; "OFI - Opportunity for Improvement"; "NCR - Nonconformance")
TRUNCATE TABLE:C1051([AuditStatus:141])
For ($i; 0; $auditStatus.length-1)
	$eAuditStatus:=ds:C1482.AuditStatus.new()
	$eAuditStatus.levelID:=$i+1
	$eAuditStatus.name:=$auditStatus[$i]
	$eAuditStatus.color:="#FFFFFF"
	$eAuditStatus.save()
End for 

//----> [ProcessType]
var $eProcessType : cs:C1710.ProcessTypeEntity
$processTypes:=New collection:C1472("Assembly"; "Assembly_AE"; "Assembly_AO"; "Assembly_AP"; "Assembly_D"; "Assembly_E"; "Assembly_M"; \
"Assembly_O"; "Assembly_W"; "Burn-In"; "Environmental"; "Environmental_B1"; "Environmental_B1, B2, B3"; "Environmental_B2"; \
"Environmental_B3"; "Environmental_B4"; "Environmental_B5"; "Environmental_B6"; "Environmental_B7"; "Environmental_B8"; \
"Environmental_C1"; "Environmental_C2"; "Environmental_C3"; "Environmental_C4"; "Environmental_D1"; "Environmental_D1, D4"; \
"Environmental_D2"; "Environmental_D3"; "Environmental_D4"; "Environmental_D5"; "Environmental_D6"; "Environmental_D7"; \
"Environmental_D8"; "Environmental_D9"; "Program Management")
TRUNCATE TABLE:C1051([ProcessType:140])
For ($i; 0; $processTypes.length-1)
	$eProcessType:=ds:C1482.ProcessType.new()
	$eProcessType.levelID:=$i+1
	$eProcessType.name:=$processTypes[$i]
	$eProcessType.color:="#FFFFFF"
	$eProcessType.save()
End for 

If (True:C214)
	TRUNCATE TABLE:C1051([DivisionInfo:68])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/divisionInfo_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($record; $records)
		$divisionInfo_e:=ds:C1482.DivisionInfo.new()
		
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($record.Div; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($division.length>0)
			$divisionInfo_e.UUID_Division:=$division[0].UUID
		Else 
			
		End if 
		
		
		$divisionInfo_e.site:=$record.Site
		$divisionInfo_e.payTo:=$record.Pay_to
		$divisionInfo_e.parent:=$record.parent
		
		$divisionInfo_e.contactDetails:=New object:C1471()
		$divisionInfo_e.contactDetails.addresses:=New collection:C1472()
		
		$address:=New object:C1471()
		$address.type:="billing"
		$address.detail:=New object:C1471()
		$address.detail.country:="US"
		$address.detail.street_1:=$record.BillingAddress1
		
		If (String:C10($record.BillingAddress2)#"")
			$add2:=Split string:C1554($record.BillingAddress2; " ")
			
			If ($add2.length>0)
				$address.detail.city:=Replace string:C233($add2[0]; ","; "")
			End if 
			
			If ($add2.length>1)
				$address.detail.state:=$add2[1]
			End if 
			
			If ($add2.length>2)
				$address.detail.postcode:=$add2[2]
			End if 
			
		End if 
		$address.detail.iso_code_2:="US"
		
		$divisionInfo_e.contactDetails.addresses.push($address)
		
		
		$address:=New object:C1471()
		$address.type:="site"
		$address.detail:=New object:C1471()
		$address.detail.country:="US"
		$address.detail.street_1:=$record.SiteAdd1
		
		If (String:C10($record.SiteAdd2)#"")
			$add2:=Split string:C1554($record.SiteAdd2; " ")
			
			If ($add2.length>0)
				$address.detail.city:=Replace string:C233($add2[0]; ","; "")
			End if 
			
			If ($add2.length>1)
				$address.detail.state:=$add2[1]
			End if 
			
			If ($add2.length>2)
				$address.detail.postcode:=$add2[2]
			End if 
			
		End if 
		$address.detail.iso_code_2:="US"
		$divisionInfo_e.contactDetails.addresses.push($address)
		
		$address:=New object:C1471()
		$address.type:="remit"
		$address.detail:=New object:C1471()
		$address.detail.country:="US"
		$address.detail.street_1:=$record.Remit_add1
		
		If (String:C10($record.Remit_add2)#"")
			$add2:=Split string:C1554($record.Remit_add2; " ")
			
			If ($add2.length>0)
				$address.detail.city:=Replace string:C233($add2[0]; ","; "")
			End if 
			
			If ($add2.length>1)
				$address.detail.state:=$add2[1]
			End if 
			
			If ($add2.length>2)
				$address.detail.postcode:=$add2[2]
			End if 
			
		End if 
		$address.detail.iso_code_2:="US"
		$divisionInfo_e.contactDetails.addresses.push($address)
		
		$res:=$divisionInfo_e.save()
		
		If (Not:C34($res.success))
			
		End if 
	End for each 
End if 


//----[StepTemplateLayout]
var $eStepTemplateLayout : cs:C1710.StepTemplateLayoutEntity
var $layouts : Collection:=New collection:C1472("bake"; "bin_wise_out"; "burnin_L"; "data_prep"; "L_Elec_test"; "L_ExpandedBins"; \
"L_plain"; "N/A"; "PDA"; "PlainUniversalWithBinsAndMark"; "WS")
TRUNCATE TABLE:C1051([StepTemplateLayout:91])
For ($i; 0; $layouts.length-1)
	$eStepTemplateLayout:=ds:C1482.StepTemplateLayout.new()
	//$eStepTemplateLayout.type:=$i
	$eStepTemplateLayout.name:=$layouts[$i]
	$eStepTemplateLayout.save()
End for 

