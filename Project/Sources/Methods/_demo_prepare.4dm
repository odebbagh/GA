//%attributes = {}
// _demo_prepare
// Fills a database with what the demo of 10 July 2026 walks through - customer received
// material and its receiving, bins, planning a lot from a step file, punch in / punch out,
// QA sign-off, the travellers, a lot hold with its NCMN approvals, tools on a step - then
// shows a cheat sheet: which codes to type, which customers have short step files, which
// step carries an alert, which one uses a microscope. The sheet is also written to
// Project/imports/demo_cheatsheet.txt.
//
// Safe on a database that already has data, and safe to run again:
// - each import runs only when its table is empty (or, for staff, when the demo people
//   are missing), so nothing already there is replaced
// - the destructive legacy importers are never called: __import_purchaseOrders,
//   _import_hk_workflow, __import_data_lists, __import_data_staff... wipe Specification,
//   Step, Staff and more
// - profile memberships and demo tools are only added when missing
// Each import shows its own message when it finishes.
//
// Not covered: the "Lot Traveller" print template. It was laid out by hand in the dfd
// editor of the previous data file and no method rebuilds it. The Production Lot
// Traveller is seeded here.
	
var $log : Collection
var $sheet : Collection
var $members : Collection
var $member : Object
var $ident : Text
var $res : Object
var $staff : 4D:C1709.Entity
var $profile : 4D:C1709.Entity
var $inscription : 4D:C1709.Entity
var $stepFile : 4D:C1709.Entity
var $customer : 4D:C1709.Entity
var $step : 4D:C1709.Entity
var $toolType : 4D:C1709.Entity
var $tool : 4D:C1709.Entity
var $link : 4D:C1709.Entity
var $linked : Integer
var $nbSteps : Integer
var $byCustomer : Object
var $row : Object
var $rows : Collection
var $key : Text
var $giver : Text
var $text : Text
var $bin : 4D:C1709.Entity
var $barcodes : Integer
	
$log:=New collection:C1472
	
// ---------------------------------------------------------------------------------
// 1. Profiles and people
// ---------------------------------------------------------------------------------
If (ds:C1482.sfw_UserProfile.query("ident IN :1"; New collection:C1472("rc"; "cs"; "qa"; "en"; "pr")).length<5)
	_import_userProfiles
End if 
	
// _import_users rebuilds every row it ever created, so it only runs when the demo people
// are not there yet
If (ds:C1482.Staff.query("code = :1"; "001492").length=0)
	_import_users
End if 
	
// ---------------------------------------------------------------------------------
// 2. Customers, then the step files that point at them
// ---------------------------------------------------------------------------------
If (ds:C1482.CustomerCarrier.all().length=0)
	_import_customerCarriers
End if 
// Vendors live in the Customer table too (vendor = True), so "no customer" means no
// non-vendor row. _import_customers truncates Customer, vendors included, so the vendors
// are imported again right after it (_import_vendors adds rows and never deletes).
If (ds:C1482.Customer.query("vendor = :1"; False:C215).length=0)
	If (ds:C1482.Customer.all().length>0)
		$log.push(String:C10(ds:C1482.Customer.all().length)+" vendor/customer row(s) created by hand were replaced by the import.")
	End if 
	_import_customers
	_import_vendors
End if 
	
// The step files were imported while there was no customer, so none could be linked.
// Re-importing them is safe: _import_steps_files only replaces StepFile, and lot steps
// point at Step, never at StepFile.
$linked:=0
For each ($stepFile; ds:C1482.StepFile.all())
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($stepFile.UUID_Customer)))
		$linked+=1
	End if 
End for each 
If ($linked=0) && (ds:C1482.Customer.all().length>0)
	_import_steps_files
End if 
	
// ---------------------------------------------------------------------------------
// 3. Reference data for receiving and production
// ---------------------------------------------------------------------------------
If (ds:C1482["InventoryClassification"]#Null:C1517)
	If (ds:C1482["InventoryClassification"].all().length=0)
		_import_inventoryClassification
	End if 
End if 
If (ds:C1482["InventoryUnits"]#Null:C1517)
	If (ds:C1482["InventoryUnits"].all().length=0)
		_import_inventoryUnits
	End if 
End if 
If (ds:C1482.Bin.all().length=0)
	_import_warehouseBins
End if 
// bins created before every creation path assigned a barcode: the imported ones and the
// sub-locations added through the location picker (BinEntity.assignBarcode)
$barcodes:=0
For each ($bin; ds:C1482.Bin.all())
	$text:=""
	If ($bin.moreData#Null:C1517)
		$text:=String:C10($bin.moreData.barcodeData)
	End if 
	If ($text="")
		$bin.assignBarcode()
		$res:=$bin.save()
		If ($res.success)
			$barcodes+=1
		End if 
	End if 
End for each 
If (ds:C1482.HoldCode.all().length=0)
	_import_holdCodes
End if 
If (ds:C1482.ToolType.all().length=0)
	_import_toolTypes
End if 
If (ds:C1482.dfd_Template.query("name = :1"; "Production Lot Traveller").length=0)
	Planning_seedPLTTemplate
End if 
	
// ---------------------------------------------------------------------------------
// 4. The demo people in the profiles the demo checks
//    001730 Donhenley Sismaet  Receiving + Production : receives the material, signs the
//                              NCMN production approval; refused for QA sign-off
//    001492 Rexie Belena       Customer Service only  : refused as "received by", as in
//                              the demo; signs the NCMN customer service approval
//    001695 Karla Dy           Quality Assurance      : QA sign-off, NCMN QA/QC approval
//    001571 Alan Pan           Engineering            : NCMN engineering approval
// ---------------------------------------------------------------------------------
$members:=New collection:C1472(\
	New object:C1471("code"; "001730"; "profiles"; New collection:C1472("rc"; "pr")); \
	New object:C1471("code"; "001492"; "profiles"; New collection:C1472("cs")); \
	New object:C1471("code"; "001695"; "profiles"; New collection:C1472("qa")); \
	New object:C1471("code"; "001571"; "profiles"; New collection:C1472("en")))
	
$giver:=""
If (cs:C1710.sfw_userManager.me.info#Null:C1517)
	$giver:=String:C10(cs:C1710.sfw_userManager.me.info.UUID)
End if 
	
For each ($member; $members)
	$staff:=ds:C1482.Staff.query("code = :1"; $member.code).first()
	Case of 
		: ($staff=Null:C1517)
			$log.push("Staff "+$member.code+" not found: profiles not set.")
			continue
		: ($staff.user=Null:C1517)
			$log.push("Staff "+$member.code+" has no application account: profiles not set.")
			continue
	End case 
	For each ($ident; $member.profiles)
		$profile:=ds:C1482.sfw_UserProfile.query("ident = :1"; $ident).first()
		If ($profile=Null:C1517)
			$log.push("Profile "+$ident+" not found (for "+$member.code+").")
			continue
		End if 
		If (ds:C1482.sfw_UserInscription.query("UUID_User = :1 AND UUID_UserProfile = :2"; $staff.user.UUID; $profile.UUID).length=0)
			$inscription:=ds:C1482.sfw_UserInscription.new()
			$inscription.UUID:=Generate UUID:C1066
			$inscription.UUID_User:=$staff.user.UUID
			$inscription.UUID_UserProfile:=$profile.UUID
			If ($giver#"")
				$inscription.UUID_whoHasGiven:=$giver
			End if 
			$inscription.stmp_given:=cs:C1710.sfw_stmp.me.now()
			$inscription.moreData:=New object:C1471("createdBy"; "_demo_prepare")
			$res:=$inscription.save()
			If (Not:C34($res.success))
				$log.push("Could not add "+$member.code+" to "+$ident+": "+JSON Stringify:C1217($res))
			End if 
		End if 
	End for each 
End for each 
	
// ---------------------------------------------------------------------------------
// 5. Microscopes for the tools part. Only when the imported data has none; one of them
//    is past its calibration date, for the expiry rule asked for in the demo.
// ---------------------------------------------------------------------------------
$toolType:=ds:C1482.ToolType.query("name = :1"; "Microscope").first()
If ($toolType=Null:C1517)
	$toolType:=ds:C1482.ToolType.new()
	$toolType.UUID:=Generate UUID:C1066
	$toolType.name:="Microscope"
	$toolType.moreData:=New object:C1471("createdBy"; "_demo_prepare")
	$res:=$toolType.save()
End if 
If (ds:C1482.Tool.query("UUID_ToolType = :1"; $toolType.UUID).length=0)
	$tool:=ds:C1482.Tool.new()
	$tool.UUID:=Generate UUID:C1066
	$tool.UUID_ToolType:=$toolType.UUID
	$tool.name:="Micro 1"
	$tool.date:=Add to date:C393(Current date:C33; 0; 6; 0)
	$tool.moreData:=New object:C1471("createdBy"; "_demo_prepare")
	$res:=$tool.save()
	
	$tool:=ds:C1482.Tool.new()
	$tool.UUID:=Generate UUID:C1066
	$tool.UUID_ToolType:=$toolType.UUID
	$tool.name:="Micro 2 (expired)"
	$tool.date:=Current date:C33-10
	$tool.moreData:=New object:C1471("createdBy"; "_demo_prepare")
	$res:=$tool.save()
End if 
	
// ---------------------------------------------------------------------------------
// 6. Cheat sheet
// ---------------------------------------------------------------------------------
$sheet:=New collection:C1472
$sheet.push("DEMO CHEAT SHEET")
$sheet.push("")
$sheet.push("Codes to type (Enter Code):")
$sheet.push("  001730  Donhenley Sismaet - Receiving + Production (receives material; refused for QA sign-off)")
$sheet.push("  001492  Rexie Belena      - Customer Service only (refused as 'received by')")
$sheet.push("  001695  Karla Dy          - Quality Assurance (QA sign-off)")
$sheet.push("  001571  Alan Pan          - Engineering (NCMN engineering approval)")
$sheet.push("  NCMN approvals: customer service 001492, engineering 001571, QA/QC 001695, production 001730")
$sheet.push("")
	
// customers with step files, shortest step file first (the demo wanted 5 or 6 steps)
$byCustomer:=New object:C1471
For each ($stepFile; ds:C1482.StepFile.all())
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($stepFile.UUID_Customer)))
		$nbSteps:=0
		If ($stepFile.stepsDefinition#Null:C1517)
			If ($stepFile.stepsDefinition.items#Null:C1517)
				$nbSteps:=$stepFile.stepsDefinition.items.length
			End if 
		End if 
		$key:=$stepFile.UUID_Customer
		If ($byCustomer[$key]=Null:C1517)
			$byCustomer[$key]:=New object:C1471("files"; 0; "shortest"; ""; "steps"; 999999)
		End if 
		$byCustomer[$key].files+=1
		If ($nbSteps>0) && ($nbSteps<$byCustomer[$key].steps)
			$byCustomer[$key].steps:=$nbSteps
			$byCustomer[$key].shortest:=String:C10($stepFile.name)
		End if 
	End if 
End for each 
$rows:=New collection:C1472
For each ($key; $byCustomer)
	$customer:=ds:C1482.Customer.get($key)
	If ($customer#Null:C1517) && ($byCustomer[$key].shortest#"")
		$rows.push(New object:C1471("customer"; $customer.name; "files"; $byCustomer[$key].files; "shortest"; $byCustomer[$key].shortest; "steps"; $byCustomer[$key].steps))
	End if 
End for each 
$sheet.push("Customers with step files (shortest step file):")
If ($rows.length=0)
	$sheet.push("  none linked")
Else 
	For each ($row; $rows.orderBy("steps asc").slice(0; 6))
		$sheet.push("  "+$row.customer+" - "+String:C10($row.files)+" file(s); \""+$row.shortest+"\" has "+String:C10($row.steps)+" steps")
	End for each 
End if 
$sheet.push("")
	
// a step that already carries an alert (shown at punch in)
$step:=ds:C1482.Step.query("alert # :1"; "").first()
If ($step#Null:C1517)
	$text:=Replace string:C233(Replace string:C233(String:C10($step.alert); "\r"; " "); "\n"; " ")
	$sheet.push("Step with an alert: "+String:C10($step.stepProcess.name)+" - "+Substring:C12(Replace string:C233(String:C10($step.description); "\r"; " "); 1; 50))
	$sheet.push("  alert: "+Substring:C12($text; 1; 80))
Else 
	$sheet.push("Step with an alert: none - set one in Housekeeping > Step Templates")
End if 
	
// a step whose template asks for a microscope (tools part)
$step:=Null:C1517
For each ($link; ds:C1482.StepTemplateToolType.query("UUID_ToolType = :1"; $toolType.UUID)) Until ($step#Null:C1517)
	$step:=ds:C1482.Step.query("UUID_StepTemplate = :1"; $link.UUIDStepTemplate).first()
End for each 
If ($step#Null:C1517)
	$sheet.push("Step using a microscope: "+String:C10($step.stepProcess.name)+" - "+Substring:C12(Replace string:C233(String:C10($step.description); "\r"; " "); 1; 50))
Else 
	$sheet.push("Step using a microscope: none - add the tool type to a template in Housekeeping")
End if 
$sheet.push("Microscopes: "+ds:C1482.Tool.query("UUID_ToolType = :1"; $toolType.UUID).extract("name").join(", "))
$sheet.push("")
	
$sheet.push("Bins given a barcode this run: "+String:C10($barcodes))
$sheet.push("Counts: customers "+String:C10(ds:C1482.Customer.all().length)+", staff "+String:C10(ds:C1482.Staff.all().length)+", bins "+String:C10(ds:C1482.Bin.all().length)+", hold codes "+String:C10(ds:C1482.HoldCode.all().length)+", step files "+String:C10(ds:C1482.StepFile.all().length))
$sheet.push("Travellers: Production Lot Traveller "+Choose:C955(ds:C1482.dfd_Template.query("name = :1"; "Production Lot Traveller").length>0; "ready"; "MISSING")+", Lot Traveller "+Choose:C955(ds:C1482.dfd_Template.query("name = :1"; "Lot Traveller").length>0; "ready"; "MISSING (laid out by hand in the old data file)"))
	
If ($log.length>0)
	$sheet.push("")
	$sheet.push("To check:")
	For each ($text; $log)
		$sheet.push("  "+$text)
	End for each 
End if 
	
Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("demo_cheatsheet.txt").setText($sheet.join("\r\n"))
ALERT:C41($sheet.join("\r"))
