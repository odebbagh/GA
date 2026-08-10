//%attributes = {}
//#DECLARE($imgPath : Text; $destinationFolder : Text)->$picture : Picture

//var $imgPath; $imgPathPOSIX; $tmpFolder; $phpPath; $result : Text

//$imgPathPOSIX:=Convert path system to POSIX($imgPath)
//$destinationFolderPOSIX:=Convert path system to POSIX($destinationFolder)

//$phpPath:=Get 4D folder(Current resources folder)+"sfw"+Folder separator+"php"+Folder separator+"images.php"

//If (Test path name($imgPath)=Is a document) & ($imgPath="@.png")

//$phpOK:=PHP Execute($phpPath; "setImageStates"; $result; $imgPathPOSIX; $destinationFolderPOSIX)

//READ PICTURE FILE($destinationFolder+$result; $picture)
//End if 