//%attributes = {"executedOnServer":true}


var $records : Collection:=New collection:C1472()


If (True:C214)
	
	$oldSystemData:=Folder:C1567(fk data folder:K87:12).file("DataJson/chartOfAcc_export.json")
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/chartOfAcount.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	$caoTypeDetails:=$records.extract("detailType").distinct()
	TRUNCATE TABLE:C1051([CAOTypeDetail:75])
	For ($i; 0; $caoTypeDetails.length-1)
		
		$typeDetail:=ds:C1482.CAOTypeDetail.new()
		$typeDetail.levelID:=$i+1
		$typeDetail.name:=$caoTypeDetails[$i]
		$typeDetail.color:=""
		$typeDetail.save()
		
	End for 
	
	
	$caoTypes:=$records.extract("type").distinct()
	TRUNCATE TABLE:C1051([CAOType:74])
	For ($i; 0; $caoTypes.length-1)
		
		$type:=ds:C1482.CAOType.new()
		$type.levelID:=$i+1
		$type.name:=$caoTypes[$i]
		$type.color:=""
		$type.save()
		
	End for 
	
	TRUNCATE TABLE:C1051([CAO:73])
	For each ($record; $records)
		
		$eChartOfAccount:=ds:C1482.CAO.new()
		$eChartOfAccount.name:=$record.fullName
		
		$caoType:=ds:C1482.CAOType.query("name =:1"; Split string:C1554($record.type; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($caoType.length>0)
			
			$eChartOfAccount.UUID_CAOType:=$caoType[0].UUID
		Else 
			
			$eChartOfAccount.UUID_CAOType:="00"*16
		End if 
		
		//$eChartOfAccount.type:=$record.type
		//$eChartOfAccount.typeDetail:=$record.detailType
		
		$caoTypeDetail:=ds:C1482.CAOTypeDetail.query("name =:1"; Split string:C1554($record.detailType; "\r"; sk trim spaces:K86:2).join("\r"))
		
		If ($caoTypeDetail.length>0)
			
			$eChartOfAccount.UUID_CAOTypeDetail:=$caoTypeDetail[0].UUID
		Else 
			
			$eChartOfAccount.UUID_CAOTypeDetail:="00"*16
		End if 
		
		$eChartOfAccount.balance:=$record.totalBalance
		$recodNumber:=ds:C1482.sfw_Counter.getNextValue("CAO")
		$eChartOfAccount.accountNumber:=String:C10($recodNumber; "00000")
		$eChartOfAccount.description:=$record.totalBalance
		$eChartOfAccount.isInacActive:=False:C215
		
		$eChartOfAccount.UUID_ParentAccount:="00"*16
		
		
		$info:=$eChartOfAccount.save()
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	End for each 
	
End if 

