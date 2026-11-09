//%attributes = {}
// _ga_createSalesDocFolders -> the document folders of the Documents tab of the Quotes and Leads
// entries, created when missing (by ident). Returns the names of the folders it created.
// Run at startup by goldenAltos_definition._documentFolders_definition; can be run by hand.
// Each folder is shown on its own entry only (moreData.allowedEntries = entry ident "quote" or
// "lead"). Names, profiles and entries can then be changed in Document Management: an existing
// folder is never modified, the ident is what this method looks for.
#DECLARE()->$created : Collection

var $definitions : Collection
var $definition : Object
var $folder; $parent : cs:C1710.sfw_DocumentFolderEntity
var $result : Object

$definitions:=[\
{ident: "quoteDocuments"; name: "Quote documents"; entry: "quote"; parent: ""}; \
{ident: "quoteRFQ"; name: "Customer RFQ & specs"; entry: "quote"; parent: "quoteDocuments"}; \
{ident: "quoteSent"; name: "Quotes sent"; entry: "quote"; parent: "quoteDocuments"}; \
{ident: "leadDocuments"; name: "Lead documents"; entry: "lead"; parent: ""}; \
{ident: "leadCorrespondence"; name: "Correspondence"; entry: "lead"; parent: "leadDocuments"}; \
{ident: "leadCustomerFiles"; name: "Customer files"; entry: "lead"; parent: "leadDocuments"}]

$created:=[]
For each ($definition; $definitions)  // parents come before their subfolders
	If (ds:C1482.sfw_DocumentFolder.query("ident = :1"; $definition.ident).length>0)
		continue
	End if 
	
	$folder:=ds:C1482.sfw_DocumentFolder.new()
	$folder.UUID:=Generate UUID:C1066
	$folder.ident:=$definition.ident
	$folder.name:=$definition.name
	$folder.UUID_ParentFolder:=16*"00"  // a top folder: the Documents page lists those first
	If ($definition.parent#"")
		$parent:=ds:C1482.sfw_DocumentFolder.query("ident = :1"; $definition.parent).first()
		If ($parent#Null:C1517)
			$folder.UUID_ParentFolder:=$parent.UUID
		End if 
	End if 
	$folder.moreData:={allowedEntries: [$definition.entry]}
	$result:=$folder.save()
	If ($result.success)
		$created.push($folder.name)
	End if 
End for each 
