//%attributes = {"executedOnServer":true}
var $eDepartment : cs:C1710.DepartmentEntity

$employee_Log:=Folder:C1567(fk data folder:K87:12).file("DataJson/employees.json")
If ($employee_Log.exists)
	$employees:=JSON Parse:C1218($employee_Log.getText())
	TRUNCATE TABLE:C1051([Department:132])
	
	For each ($employee; $employees)
		$eemployee:=ds:C1482.Employee.new()
		$eemployee.lastName:=$employee.Last_Name
		$eemployee.firstName:=$employee.Last_Name
		$eemployee.code:=$employee.Employee_Code
		$eemployee.active:=Not:C34($employee.Emp_Terminated)
		
		$eemployee.contactDetails:=New object:C1471()
		$eemployee.contactDetails.communications:=New collection:C1472()
		
		$comm:=New object:C1471()
		If ($employee.Telephone#"")
			$comm.phone:=$employee.Telephone
		End if 
		If ($employee.Fax#"")
			$comm.fax:=$employee.Fax
		End if 
		If ($employee.Mobile#"")
			$comm.mobile:=$employee.Mobile
		End if 
		If ($employee.EmailAddress#"")
			$comm.email:=$employee.EmailAddress
		End if 
		If ($employee.Telephone#"") || ($employee.Fax#"") || ($employee.Mobile#"") || ($employee.EmailAddress#"")
			$eemployee.contactDetails.communications.push($comm)
		End if 
		
		If ($employee.Department#"")
			$eDepartment:=ds:C1482.Department.query("name == :1"; $employee.Department).first()
			If ($eDepartment=Null:C1517)
				$eDepartment:=ds:C1482.Department.new()
				$eDepartment.name:=$employee.Department
				$eDepartment.save()
			End if 
			$eemployee.UUID_Department:=$eDepartment.UUID
		End if 
		
		
		$result:=$eemployee.save()
		If ($result.success=False:C215)
			TRACE:C157
		End if 
	End for each 
	
	
	
End if 