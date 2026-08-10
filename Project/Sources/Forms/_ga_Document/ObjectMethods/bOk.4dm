

Case of 
		
		
	: (Form event code:C388=On Clicked:K2:4)
		
		var $attributesCol : Collection:=New collection:C1472()
		OB GET PROPERTY NAMES:C1232(Form:C1466.details.clone; $attributes)
		ARRAY TO COLLECTION:C1563($attributesCol; $attributes)
		For each ($attribute; $attributesCol)
			If ($attribute#"blob")
				If (Form:C1466.details[$attribute]#Form:C1466.details.clone[$attribute])
					Form:C1466.modified:=True:C214
					$buffer:=New object:C1471()
					$buffer.event:="modifyDocument"
					$buffer.label:="Document "+Form:C1466.details.sourcePath+" "+$attribute+" : "+Form:C1466.details.clone[$attribute]+"->"+Form:C1466.details[$attribute]
					$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
					Form:C1466.bufferOfEvents.push($buffer)
				End if 
			End if 
		End for each 
		
		OB REMOVE:C1226(Form:C1466.details; "clone")
		
		
		If (Form:C1466.hasAuthorizationToApprove)
			Case of 
				: (ds:C1482.Staff.query("code =:1"; Form:C1466.details.approvedBy).first()=Null:C1517) & (Form:C1466.details.isApproved)
					cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("Emplyee Code Error"; "There is no GA Staff member with this Emplyee code!"))
					
				: (Form:C1466.details.approvalDate=Date:C102(!00-00-00!)) & (Form:C1466.details.isApproved)
					cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff(""; "The approval date is Null!"))
					
					
				Else 
					
					ACCEPT:C269
			End case 
			
		Else 
			
			ACCEPT:C269
		End if 
		
	Else 
		
		
End case 