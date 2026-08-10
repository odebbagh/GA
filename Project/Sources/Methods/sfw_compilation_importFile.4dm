//%attributes = {}


$document:=Select document:C905(""; "*"; "Sélectionner le fichier contenant les utilisateurs"; 16)  //use XLIFF
If (OK=1)
	$jsonCompilation:=Document to text:C1236(document; "UTF-8")
	$compilation:=JSON Parse:C1218($jsonCompilation)
	
	$result:=sfw_compile_getInfo($compilation; document)
	Form:C1466.subForm.compilation_ResultLabel:=$result.compilation_ResultLabel
	Form:C1466.subForm.compilationErrors:=$result.compilationErrors
	Form:C1466.subForm.compilation_nbErrors:=$result.compilation_nbErrors
	Form:C1466.subForm.compilation_nbWarnings:=$result.compilation_nbWarnings
	Form:C1466.subForm.compilation_label:=$result.compilation_label
End if 

