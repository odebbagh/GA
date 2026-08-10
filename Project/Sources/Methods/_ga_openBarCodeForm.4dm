//%attributes = {}
/*
_ga_openBarCodeForm

*/


$form:=New object:C1471
If (Form:C1466.current_item.moreData#Null:C1517)
	
	If (OB Is defined:C1231(Form:C1466.current_item.moreData; "barcodeData"))
		$form.barcodeData:=Form:C1466.current_item.moreData.barcodeData
		$form.fieldsNames:=New collection:C1472()
		$form.current_item:=Form:C1466.current_item
		For ($i; 1; Last table number:C254)
			If (Is table number valid:C999($i))
				If (Table name:C256($i)=Form:C1466.sfw.entry.dataclass)
					
					For ($j; 1; Last field number:C255($i))
						If (Is table number valid:C999($j))
							GET FIELD PROPERTIES:C258($i; $j; $fieldType)
							
							If ($fieldType#Is object:K8:27) & ($fieldType#Is BLOB:K8:12) & ($fieldType#Is date:K8:7) & ($fieldType#Is picture:K8:10) & ($fieldType#Is boolean:K8:9)
								$fieldName:=Field name:C257($i; $j)
								
								If ($fieldName#"UUID") & ($fieldName#"UUID_@") & ($fieldName#"stmp@") & ($fieldName#"@stmp")
									$form.fieldsNames.push($fieldName)
								End if 
								
							End if 
							
						End if 
						
					End for 
					
					//$tablePtr:=Table($i)
					//GET FIELD TITLES(Table($i)->; $fieldTitles; $fieldsNums)
					//ARRAY TO COLLECTION($form.fieldsNames; $fieldTitles)
					
					break
				End if 
				
			End if 
		End for 
		
		$winRef:=Open form window:C675("_ga_generateBarCode"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
		SET WINDOW TITLE:C213("Generate Bar code "; $winRef)  //for "+String(Form.current_item.fullName)
		DIALOG:C40("_ga_generateBarCode"; $form)
		
	Else 
		ALERT:C41("Not data for the barcode")
	End if 
Else 
	ALERT:C41("Not data for the barcode")
End if 


//If (Form.lastPanelDisplayed="sfw_panel_user")
//$form.barcodeData:=Form.current_item.UUID
//Else 
//$form.barcodeData:=Form.current_item.moreData.barcodeData
//End if 

//$form.fieldsNames:=New collection()
//GET FIELD TITLES([sfw_User]; $fieldTitles; $fieldsNums)
//ARRAY TO COLLECTION($form.fieldsNames; $fieldTitles)








