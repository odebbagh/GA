//%attributes = {}

WA OPEN URL:C1020(*; This:C1470.area; This:C1470.url)

Case of 
		
	: ($1="encoder")  //QR CODE
		
		If (FORM Event:C1606.code=On End URL Loading:K2:47)
			$js:="document.getElementById('canvas').getElementsByTagName('img')[0].src"
			
			This:C1470.result:=WA Evaluate JavaScript:C1029(*; This:C1470.area; $js)
		End if 
		
	: ($1="decoder")  //QR CODE
		
		If (FORM Event:C1606.code=On End URL Loading:K2:47)
			DELAY PROCESS:C323(Current process:C322; 120)
			//$base64Image:="data:image/png;base64,"+This.base64Image
			
			Repeat 
				$title:=WA Get page title:C1036(*; This:C1470.area)
			Until ($title="DECODAGE_TERMINE")
			
			//$jsCode:="decodeQR("+JSON Stringify($base64Image)+")"
			
			$js:="document.getElementById('result-box').innerText"
			This:C1470.result:=WA Evaluate JavaScript:C1029(*; This:C1470.area; $js)  // $jsCode)
		End if 
		
	: ($1="GenerateBarCode")  //BARCODE
		
		If (FORM Event:C1606.code=On End URL Loading:K2:47)
			$js:="document.getElementById('result-box').getAttribute('data-base64')"
			
			This:C1470.result:=WA Evaluate JavaScript:C1029(*; This:C1470.area; $js)
		End if 
		
	: ($1="readBarCode")  //BARCODE
		
		If (FORM Event:C1606.code=On End URL Loading:K2:47)
			DELAY PROCESS:C323(Current process:C322; 120)
			//$base64Image:="data:image/png;base64,"+This.base64Image
			
			Repeat 
				$title:=WA Get page title:C1036(*; This:C1470.area)
			Until ($title="DECODAGE_TERMINE")
			
			//$jsCode:="decodeQR("+JSON Stringify($base64Image)+")"
			
			$js:="document.getElementById('result-box').innerText"
			This:C1470.result:=WA Evaluate JavaScript:C1029(*; This:C1470.area; $js)  // $jsCode)
		End if 
		
		
End case 
