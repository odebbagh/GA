//%attributes = {}
#DECLARE($num : Integer)

$processName:="sfw_toolbar"

If (Count parameters:C259=0)
	
	$process:=New process:C317(Current method name:C684; 0; $processName; 1; *)
	
Else 
	
	SET MENU BAR:C67(1)
	
	Repeat 
		
		$formData:=New object:C1471
		$formData.sfw:=cs:C1710.sfw_toolbar.new()
		$formData.sfw.vision:=cs:C1710.sfw_definition.me.visions.query("label # :1"; "-").orderBy("displayOrder desc")[0]
		DELAY PROCESS:C323(Current process:C322; 60)  //wait for the 4D interface initialization or update (in case of "restart interpreted")
		
		$toolbarWindow:=cs:C1710.sfw_window.me.openFormWindow("sfw_toolbar"; Toolbar form window:K39:16)
		DIALOG:C40("sfw_toolbar"; $formData)
		cs:C1710.sfw_window.me.closeWindow($toolbarWindow)
		
	Until (ok=0) | (Process aborted:C672)
	
End if 