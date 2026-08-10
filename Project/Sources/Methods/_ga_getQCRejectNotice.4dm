//%attributes = {"executedOnServer":true}

var $blob : Blob
$sampleFile:=Get 4D folder:C485(Current resources folder:K5:16)+"pdfForms"+Folder separator:K24:12+"QC_QC Rejection Notice.pdf"
DOCUMENT TO BLOB:C525($sampleFile; $blob)

$0:=$blob