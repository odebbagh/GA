format_date_time
PrintedTravStepFmt
// Put this here
Case of 
	: (Form event code:C388=On Load:K2:1) | (Form event code:C388=On Printing Detail:K2:18)
		Case of 
			: (IsDeviceTableLinked=True:C214) & (([Template_definitions:49]MiscellaneousControl:42 & 0x0200)=0x0200)
			Else 
				OBJECT SET VISIBLE:C603(Markpict; False:C215)
				OBJECT SET VISIBLE:C603(*; "MarkPicture"; False:C215)
		End case 
End case 