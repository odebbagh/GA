Case of 
		
	: (Form event code:C388=On Load:K2:1)
		
		If (Form:C1466.readOnly=Null:C1517)
			Form:C1466.readOnly:=False:C215
		End if 
		If (Form:C1466.saveAndNew=Null:C1517)
			Form:C1466.saveAndNew:=False:C215
		End if 
		
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.bins=Null:C1517)
			ds:C1482.Bin.cacheLoad()
		End if 
		Form:C1466.currentPath:=""
		If (Form:C1466.inventory_e.UUID_InventoryClassification#"") & (Form:C1466.inventory_e.UUID_InventoryClassification#String:C10("00"*16))
			$classification:=ds:C1482.InventoryClassification.query("UUID = :1"; Form:C1466.inventory_e.UUID_InventoryClassification).first()
			If ($classification#Null:C1517)
				Form:C1466.inventory_e.classification:=$classification.name
			End if 
		End if 
		If (Form:C1466.inventory_e.UUID_InventoryUnits#"") & (Form:C1466.inventory_e.UUID_InventoryUnits#String:C10("00"*16))
			$inventoryUnit:=ds:C1482.InventoryUnits.query("UUID = :1"; Form:C1466.inventory_e.UUID_InventoryUnits).first()
			If ($inventoryUnit#Null:C1517)
				Form:C1466.inventory_e.units:=$inventoryUnit.name
			End if 
		End if 
		If (Form:C1466.inventory_e.UUID_Location#"") & (Form:C1466.inventory_e.UUID_Location#String:C10("00"*16))
			
			Form:C1466.selectedBins:=Storage:C1525.cache.bins.query("UUID = :1"; Form:C1466.inventory_e.UUID_Location)
			If (Form:C1466.selectedBins#Null:C1517)
				Form:C1466.currentPath:=Form:C1466.selectedBins.first().binLocationPath
				OBJECT SET TITLE:C194(*; "pup_binLocation"; Form:C1466.currentPath)
				//cs.Util_binLocationPicker.me.draw("pup_binLocation"; Form.currentPath)
			End if 
			
		End if 
		
		Form:C1466.inventory_e.dateIn:=Current date:C33(*)
		
		If (Form:C1466.inventory_e.UUID_Staff=("0"*32))
			Form:C1466.receivedBy:=""
		Else 
			Form:C1466.receivedBy:=Form:C1466.inventory_e.receiver.code
		End if 
		
		If (Form:C1466.readOnly)
			// Visu mode: keep dialog informational only.
			OBJECT SET ENABLED:C1123(*; "Input"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input3"; False:C215)
			OBJECT SET ENABLED:C1123(*; "fld_classification"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input7"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input4"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input6"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input9"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input10"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input5"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Input13"; False:C215)
			OBJECT SET ENABLED:C1123(*; "pup_binLocation"; False:C215)
			OBJECT SET ENABLED:C1123(*; "btnDatePicker_dateIn"; False:C215)
			OBJECT SET ENABLED:C1123(*; "btnDatePicker_expirationDate"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Button1"; False:C215)
			OBJECT SET ENABLED:C1123(*; "btnSaveAndNew"; False:C215)
		End if 
		
	: (Form event code:C388=On Validate:K2:27)
		
		If (Form:C1466.readOnly)
			// View mode: no entry validation.
		Else 
			var $profileCheck : Object
			
			If (Form:C1466.inventory_e.UUID_Staff="") | (Form:C1466.inventory_e.UUID_Staff=(String:C10("0"*32)))
				cs:C1710.sfw_dialog.me.alert("Received By is required.")
				CANCEL:C270
			Else 
				$profileCheck:=Staff_isInUserProfile(Form:C1466.receivedBy; "Rec")
				If (Not:C34($profileCheck.isInProfile))
					cs:C1710.sfw_dialog.me.alert("This user is not part of the Receiving profile and cannot be set as Received By.")
					CANCEL:C270
				End if 
			End if 
		End if 
		
End case 
