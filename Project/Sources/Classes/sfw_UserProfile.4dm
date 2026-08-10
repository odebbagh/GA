Class extends DataClass


local Function getAndCreateIfNotExist($ident : Text; $name : Text;  ...  : Text)->$eProfil : cs:C1710.sfw_UserProfileEntity
	
	If (Application type:C494#4D Remote mode:K5:5)
		$eProfil:=This:C1470.query("ident = :1"; $ident).first()
		If ($eProfil=Null:C1517)
			$eProfil:=This:C1470.new()
			$eProfil.UUID:=Generate UUID:C1066
			$eProfil.ident:=$ident
			$eProfil.name:=$name
			$eProfil.moreData:=New object:C1471
			For ($i; 3; Count parameters:C259)
				$param:=${$i}
				Case of 
					: ($param="autoCreation")
						$eProfil.moreData.autoCreation:=cs:C1710.sfw_stmp.me.now()
				End case 
			End for 
			$info:=$eProfil.save()
		End if 
	End if 
	
	
	
	
local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("profile"; "userManagement"; "Profiles")  //okXLIFF
	$entry.setXliffLabel("profile.profiles")
	$entry.setDataclass("sfw_UserProfile")
	
	$entry.setIcon("sfw/entry/profile-50x50.png")
	
	$entry.setSearchboxField("ident")
	
	$entry.setPanel("sfw_panel_profile")
	$entry.setPanelPage(1; ""; "Permissions")  //okXLIFF
	
	$entry.setLBItemsColumn("ident"; "Identifier"; "width:65"; "xliff:profile.field.ident")
	$entry.setLBItemsColumn("name"; "Name"; "xliff:profile.field.name")
	
	$entry.setLBItemsOrderBy("ident")
	
	$entry.setLBItemsCounter("###0###0##0^1;;"; "unit1: profile"; "unitN: profiles"; "unit1xliff:profile.single"; "unitNxliff:profile.plural")  //okXLIFF
	
	$entry.setAddable()
	
	$entry.setAllowedProfiles(cs:C1710.sfw_globalParameters.me.userVision.entryProfile.allowedProfiles || "admin")
	
	$entry.enableTransaction()
	
	$entry.setValidationRule("ident"; "entryField_ident"; "mandatory"; "trimSpace"; "capitalize"; "message:The ident is mandatory")
	$entry.setValidationRule("ident"; "entryField_ident"; "unique"; "message:The ident must be unique")
	$entry.setValidationRule("name"; "entryField_name"; "mandatory"; "trimSpace"; "capitalize"; "capitalize"; "message:The name is mandatory")
	
	
	
local Function closeBoxMainForm()
	If (Form:C1466.subForm#Null:C1517) && (Form:C1466.subForm.hl_permissions#Null:C1517) && (Is a list:C621(Form:C1466.subForm.hl_permissions))
		CLEAR LIST:C377(Form:C1466.subForm.hl_permissions; *)
	End if 
	If (Form:C1466.subForm#Null:C1517) && (Form:C1466.subForm.hl_entryPermissions#Null:C1517) && (Is a list:C621(Form:C1466.subForm.hl_entryPermissions))
		CLEAR LIST:C377(Form:C1466.subForm.hl_entryPermissions; *)
	End if 