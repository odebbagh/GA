//%attributes = {}

/*
Method Name : _ga_installHoldFormModels
Purpose     : Puts the two hold forms into [sfw_DocumentModel], so they show in Document
              Management > Models and are edited there with the Write Pro editor:
                GAF-1014  Non-Conforming Material Notice     printed from the NCMN window
                GAF-1514  Internal Start/Stop Notification   printed from the ISSNF window
              (LotHoldForm_print reads them by these names).

HOW TO USE IT
  Run it once. It writes the seed files (_ga_buildHoldFormTemplates), then imports each one
  into its model. Re-running it asks before replacing a model: anything laid out in the editor
  would be lost.

NEW REVISION OF A FORM
  Edit the model: the fixed text ("GAF-1014, Rev. 08", labels, titles) is plain text there.
  To keep the old revision, duplicate the model first and rename the copy (for example
  "GAF-1014 Rev 08"): the print always uses the model named exactly GAF-1014.
  Only a new value on the form (a new {{token}}) needs LotHoldForm_printContext.
*/

var $folder : cs:C1710.sfw_DocumentFolderEntity
var $folders : cs:C1710.sfw_DocumentFolderSelection
var $installed : Collection

$folder:=ds.sfw_DocumentFolder.query("name = :1"; "Documents management").first()
If ($folder=Null)
	$folders:=ds.sfw_DocumentFolder.all().orderBy("name asc")
	If ($folders.length>0)
		$folder:=$folders.first()
	End if
End if
If ($folder=Null)
	cs.sfw_dialog.me.alert("There is no document folder to put the models in."+Char(Carriage return)\
		+"Create one in Document Management first.")
	return
End if

_ga_buildHoldFormTemplates

$installed:=New collection()
_ga_installOneWPModel("GAF-1014"; "GAF-1014.4wp"; $folder; $installed)
_ga_installOneWPModel("GAF-1514"; "GAF-1514.4wp"; $folder; $installed)

If ($installed.length=0)
	cs.sfw_dialog.me.alert("Nothing was installed.")
Else
	cs.sfw_dialog.me.info($installed.join(Char(Carriage return))+Char(Carriage return)+Char(Carriage return)\
		+"Folder: "+$folder.name+Char(Carriage return)\
		+"Print them from the NCMN / ISSNF windows (Print button) or from the hold list menu. "\
		+"Edit them in Document Management > Models: the print reads the model, not the file.")
End if
