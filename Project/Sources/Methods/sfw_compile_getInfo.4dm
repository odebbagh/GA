//%attributes = {}
#DECLARE($compilationResult : Object; $filePath : Text)->$result : Object


$result:=New object:C1471()

If ($compilationResult.success)
	$result.compilationErrors:=New collection:C1472()
	$result.compilation_ResultLabel:=ds:C1482.sfw_readXliff("entry.compilation.compilationSuccess")
	$result.compilation_nbErrors:="0 "+ds:C1482.sfw_readXliff("entry.compilation.errors")
	$result.compilation_nbWarnings:="0 "+ds:C1482.sfw_readXliff("entry.compilation.warnings")
Else 
	
	$result.compilationErrors:=$compilationResult.errors
	$nbErrors:=$result.compilationErrors.query("isError == :1"; True:C214).length
	$nbWarnings:=$result.compilationErrors.query("isError == :1"; False:C215).length
	
	$result.compilation_ResultLabel:=ds:C1482.sfw_readXliff("entry.compilation.compilationFail")
	$result.compilation_nbErrors:=String:C10($nbErrors)+" "+ds:C1482.sfw_readXliff("entry.compilation.errors")
	$result.compilation_nbWarnings:=String:C10($nbWarnings)+" "+ds:C1482.sfw_readXliff("entry.compilation.warnings")
End if 

If (String:C10($filePath)="")
	$result.compilation_label:=ds:C1482.sfw_readXliff("entry.compilation.thisProject")
Else 
	$result.compilation_label:=ds:C1482.sfw_readXliff("entry.compilation.fileProject")+" "+$filePath
End if 