

Case of 
		
		
	: (Form event code:C388=On Clicked:K2:4)
		
		//var $attributesCol : Collection:=New collection()
		//OB GET PROPERTY NAMES(Form.details.clone; $attributes)
		//ARRAY TO COLLECTION($attributesCol; $attributes)
		//For each ($attribute; $attributesCol)
		//If ($attribute#"blob")
		//If (Form.details[$attribute]#Form.details.clone[$attribute])
		//Form.modified:=True
		//$buffer:=New object()
		//$buffer.event:="modifyDocument"
		//$buffer.label:="Document "+Form.details.sourcePath+" "+$attribute+" : "+Form.details.clone[$attribute]+"->"+Form.details[$attribute]
		//$buffer.stmp:=cs.sfw_stmp.me.now()
		//Form.bufferOfEvents.push($buffer)
		//End if 
		//End if 
		//End for each 
		
		//OB REMOVE(Form.details; "clone")
		
		
		//If (Form.hasAuthorizationToApprove)
		
		//Else 
		
		//ACCEPT
		//End if 
		
	Else 
		
		
End case 