//%attributes = {}
var $name : Text
var $numLine : Integer

$name:=OBJECT Get name:C1087(Object current:K67:2)
Form:C1466.numLine:=Num:C11(Substring:C12($name; Length:C16("bLineInRulers@")))

CALL SUBFORM CONTAINER:C1086(-100)
