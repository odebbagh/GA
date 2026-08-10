


Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		$compilationResult:=Compile project:C1760
		$result:=sfw_compile_getInfo($compilationResult)
		Form:C1466.compilation_ResultLabel:=$result.compilation_ResultLabel
		Form:C1466.compilationErrors:=$result.compilationErrors
		Form:C1466.compilation_nbErrors:=$result.compilation_nbErrors
		Form:C1466.compilation_nbWarnings:=$result.compilation_nbWarnings
		Form:C1466.compilation_label:=$result.compilation_label
End case 