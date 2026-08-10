//%attributes = {}


$compilation:=New object:C1471()
$compilation.errors:=Form:C1466.subForm.selected_compilationErrors
$compilation.success:=Choose:C955($compilation.errors.length=0; True:C214; False:C215)

$doc_ref:=Create document:C266(""; "json")
If (OK=1)
	CLOSE DOCUMENT:C267($doc_ref)
	TEXT TO DOCUMENT:C1237(Document; JSON Stringify:C1217($compilation); "UTF-8")
End if 

