//%attributes = {}
//$dropbox_folder:=Get 4D folder(Database folder)+"dropbox"+Folder separator


//$folder_icon:=$dropbox_folder+"icon"+Folder separator
//$folder_btn:=$dropbox_folder+"btn4states"+Folder separator
//DOCUMENT LIST($folder_icon; $_document_icon)
//DOCUMENT LIST($folder_btn; $_document_btn)
//For ($i; 1; Size of array($_document_icon); 1)
//If (Find in array($_document_btn; $_document_icon{$i})<=0) & ($_document_icon{$i}#".@")
//$image:=sfw_tool_icon_create4states($folder_icon+$_document_icon{$i}; $folder_btn)
//End if 
//End for 
