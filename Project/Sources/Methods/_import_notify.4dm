//%attributes = {}
// _import_notify($options; $message)
// How an importer tells its result: a dialog when run by hand, or - unattended (the
// _import_accounting / _import_all runs, $options.unattended True) - a line in
// Project/imports/import_messages.txt, so a long run never stops on a message.
#DECLARE($options : Object; $message : Text)
var $file : 4D.File
var $old : Text
If ($options#Null) && Bool($options.unattended)
	$file:=Folder(fk database folder).folder("Project/imports").file("import_messages.txt")
	$old:=$file.exists ? $file.getText() : ""
	$file.setText($old+String(Current date; ISO date)+" "+String(Current time)+"  "+Current method name+Char(Carriage return)+Char(Line feed)+Replace string($message; Char(Carriage return); Char(Carriage return)+Char(Line feed)+"    ")+Char(Carriage return)+Char(Line feed)+Char(Carriage return)+Char(Line feed))
Else 
	ALERT($message)
End if 
