//%attributes = {}
#DECLARE($param : Object)

$styleSheetText:=WP New style sheet:C1650(Form:C1466.WPareaCatalog; $param.type; $param.name)

For each ($ob; $param)
	Case of 
		: (($ob="name") | ($ob="type") | ($ob=""))
		Else 
			WP SET ATTRIBUTES:C1342($styleSheetText; $ob; $param[$ob])
	End case 
	
End for each 

$0:=$styleSheetText
