//%attributes = {}

/*
Method Name : _ga_installBuyOrderModel
Purpose     : Puts the generated print templates into [sfw_DocumentModel] so they appear
              in Document Management > Models and can be edited there with the Write Pro
              editor - the same place "Job Lots Summary WP", CERT_TRAINING and RECV_TAG
              live.

HOW TO USE IT
  1. _ga_buildBuyOrderTemplate   writes Resources/.../buyOrderPrintTemplate.4wp
  2. this method                 imports that file into a document model named BUY_ORDER
  3. from then on EDIT THE MODEL, not the file. BuyingOrders_printBuyOrder reads the
     model and only falls back to the file when no model exists.

  Re-running this method overwrites the model's content from the file, so it asks first
  and will throw away anything you laid out in the editor.

WHAT IT SETS
  name                   BUY_ORDER / BUY_RECEIPT - the key the print methods query on
  type                   2, which is what the panel treats as 4D Write Pro
  UUID_DocumentFolder    mandatory in practice: the documents page lists models by
                         folder, so a model without one is invisible in the UI
  area                   the Write Pro document itself
*/

var $folder : cs:C1710.sfw_DocumentFolderEntity
var $folders : cs:C1710.sfw_DocumentFolderSelection
var $templates : Collection
var $template : Object
var $installed : Collection

$folder:=ds.sfw_DocumentFolder.query("name = :1"; "Documents management").first()
If ($folder=Null)
	$folders:=ds.sfw_DocumentFolder.all().orderBy("name asc")
	If ($folders.length>0)
		$folder:=$folders.first()
	End if
End if

If ($folder=Null)
	cs.sfw_dialog.me.alert("There is no document folder to put the model in."+Char(Carriage return)\
		+"Create one in Document Management first.")
	return
End if

//---The buy-order prints, plus the three quality terms documents lifted straight out of
//   the legacy database (DataJson/BuyOrderTerms*.4wp - the very documents BuyOrderPrintJob
//   appended after each PO). Installing them as models is what puts the QUALITY TERMS AND
//   CONDITIONS back on the end of the print, and it means they are edited in the app
//   rather than as loose files.
//
//   A missing file is skipped, so the receipt installs itself as soon as its template
//   exists.
$templates:=New collection(\
	New object("model"; "BUY_ORDER"; "file"; "buyOrderPrintTemplate.4wp"); \
	New object("model"; "BUY_RECEIPT"; "file"; "receiptPrintTemplate.4wp"); \
	New object("model"; "BUY_ORDER_TERMS"; "file"; "buyOrderTerms.4wp"); \
	New object("model"; "BUY_ORDER_TERMS_MATERIALS"; "file"; "buyOrderTermsCriticalMaterials.4wp"); \
	New object("model"; "BUY_ORDER_TERMS_SERVICE"; "file"; "buyOrderTermsCriticalService.4wp"))

$installed:=New collection()

For each ($template; $templates)
	_ga_installOneWPModel($template.model; $template.file; $folder; $installed)
End for each

If ($installed.length=0)
	cs.sfw_dialog.me.alert("Nothing was installed."+Char(Carriage return)\
		+"Run _ga_buildBuyOrderTemplate first to generate a template file.")
Else
	cs.sfw_dialog.me.info($installed.join(Char(Carriage return))+Char(Carriage return)+Char(Carriage return)\
		+"Folder: "+$folder.name+Char(Carriage return)\
		+"Edit them in Document Management > Models from now on - the print reads the model, not the file.")
End if