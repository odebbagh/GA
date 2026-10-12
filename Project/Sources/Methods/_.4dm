//%attributes = {}
_import_stepProperties
_import_steps
_import_gafLinks
TRACE:C157
////%attributes = {}
//// Generates Resources/4DWriteProPrintTemplates/buyOrderPrintTemplate.4wp.
////
//// This is a STARTING POINT, not the finished PO. It emits every field
//// BuyingOrders_printBuyOrder puts in the data context, one per line, as
//// "Label: <formula>", plus the Tabl@ marker paragraph where the line table goes.
//// Open it in the Write Pro editor afterwards and move things into the legacy layout -
//// the formulas travel with you, so nothing has to be retyped.
////
//// Re-running overwrites the file. Do NOT re-run once you have laid it out.

//var $doc : Object
//var $range : Object
//var $field : Object
//var $fields : Collection
//var $folder : 4D.Folder
//var $file : 4D.File

//$folder:=Folder(fk resources folder).folder("4DWriteProPrintTemplates")
//If (Not($folder.exists))
//$folder.create()
//End if 
//$file:=$folder.file("buyOrderPrintTemplate.4wp")

//If ($file.exists)
//If (Not(cs.sfw_dialog.me.confirm("buyOrderPrintTemplate.4wp already exists. Overwrite it?"; "Overwrite"; "CANCEL")))
//return 
//End if 
//End if 

//$doc:=WP New("")

////---title
//$range:=WP Text range($doc; wk end text; wk end text)
//WP Insert formula($range; Formula from string("This.potitle"); wk include in range)
//WP SET ATTRIBUTES($range; wk font size; 18)
//WP SET ATTRIBUTES($range; wk font bold; wk true)
//$range:=WP Text range($doc; wk end text; wk end text)
//WP SET TEXT($range; Char(Carriage return); wk append; wk include in range)

////---the requisition warning, red
//$range:=WP Text range($doc; wk end text; wk end text)
//WP Insert formula($range; Formula from string("This.title"); wk include in range)
//WP SET ATTRIBUTES($range; wk text color; "#FF0000")
//$range:=WP Text range($doc; wk end text; wk end text)
//WP SET TEXT($range; Char(Carriage return)+Char(Carriage return); wk append; wk include in range)

////---every context key, in the order the legacy form laid them out
//$fields:=New collection(\
New object("label"; "PO number"; "key"; "poNumber"); \
New object("label"; "Issue date"; "key"; "issueDate"); \
New object("label"; "Issued to"; "key"; "vendorBlock"); \
New object("label"; "Ship to"; "key"; "shipTo"); \
New object("label"; "Bill to 1"; "key"; "billTo1"); \
New object("label"; "Bill to 2"; "key"; "billTo2"); \
New object("label"; "Attn"; "key"; "attentionTo"); \
New object("label"; "Fax"; "key"; "attentionFax"); \
New object("label"; "Tel"; "key"; "attentionTel"); \
New object("label"; "Discount"; "key"; "discount"); \
New object("label"; "Discount days"; "key"; "discountDays"); \
New object("label"; "Net days"; "key"; "netDays"); \
New object("label"; "Ship via"; "key"; "shipVia"); \
New object("label"; "Delivery terms"; "key"; "fob"))

//For each ($field; $fields)
//_wpAppendField($doc; $field.label; $field.key)
//End for each 

////---the marker the print replaces with the line table
//$range:=WP Text range($doc; wk end text; wk end text)
//WP SET TEXT($range; Char(Carriage return)+"Tabl@"+Char(Carriage return); wk append; wk include in range)

////---totals and footer
//$fields:=New collection(\
New object("label"; "Currency note"; "key"; "currencyNote"); \
New object("label"; "Currency"; "key"; "currency"); \
New object("label"; "Total"; "key"; "total"); \
New object("label"; "Additional terms"; "key"; "addTerms"); \
New object("label"; "Requestor"; "key"; "requestor"); \
New object("label"; "Buyer"; "key"; "buyer"); \
New object("label"; "Buyer contact"; "key"; "buyerContact"); \
New object("label"; "Approver 1 caption"; "key"; "approverText"); \
New object("label"; "Approver 1"; "key"; "approver1"); \
New object("label"; "Approver 2 caption"; "key"; "approverText2"); \
New object("label"; "Approver 2"; "key"; "approver2"); \
New object("label"; "Page footer"; "key"; "pageFooter"))

//For each ($field; $fields)
//_wpAppendField($doc; $field.label; $field.key)
//End for each 

//WP EXPORT DOCUMENT($doc; $file.platformPath; wk 4wp)

//cs.sfw_dialog.me.info("Template written to:"+Char(Carriage return)+$file.platformPath+Char(Carriage return)+Char(Carriage return)+"Open it in the Write Pro editor to lay it out. Do not run this again afterwards - it overwrites.")