//%attributes = {}

var $records : Collection
var $record : Object
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

$records:=New collection:C1472()

ALL RECORDS:C47([LotSteps])

While (Not:C34(End selection:C36([LotSteps])))
	$record:=New object:C1471()
	$record.Lotnum:=[LotSteps]Lotnum
	$record.LotStepNumber:=[LotSteps]LotStepNumber
	$record.StepDesc:=[LotSteps]StepDesc
	$record.QtyIn:=[LotSteps]QtyIn
	$record.DateIn:=[LotSteps]DateIn
	$record.Timein:=[LotSteps]Timein
	$record.QtyOut:=[LotSteps]QtyOut
	$record.DateOut:=[LotSteps]DateOut
	$record.TimeOut:=[LotSteps]TimeOut
	$record.Operator:=[LotSteps]Operator
	$record.Supervisor:=[LotSteps]Supervisor
	$record.QASignOff:=[LotSteps]QASignOff
	$record.Tool1:=[LotSteps]Tool1
	$record.Tool2:=[LotSteps]Tool2
	$record.Tool3:=[LotSteps]Tool3
	$record.Rejects:=[LotSteps]Rejects
	$record.Step_Comment:=[LotSteps]Step_Comment
	$record.Step_Type:=[LotSteps]Step_Type
	$record.Bin1:=[LotSteps]Bin1
	$record.Bin2:=[LotSteps]Bin2
	$record.Bin3:=[LotSteps]Bin3
	$record.Bin7:=[LotSteps]Bin7
	$record.Bin8:=[LotSteps]Bin8
	$record.Bin9:=[LotSteps]Bin9
	$record.Bin10:=[LotSteps]Bin10
	$record.MechanicalRejects:=[LotSteps]MechanicalRejects
	$record.Exception:=[LotSteps]Exception
	$record.Yield:=[LotSteps]Yield
	$record.ControlSpec:=[LotSteps]ControlSpec
	$record.ControlSpec_Rev:=[LotSteps]ControlSpec_Rev
	$record.Comment1:=[LotSteps]Comment1
	$record.Comment2:=[LotSteps]Comment2
	$record.Is_Archived:=[LotSteps]Is_Archived
	$record.ActualHours:=[LotSteps]ActualHours
	$record.UnlockStep:=[LotSteps]UnlockStep
	$record.Popup_Alert_On:=[LotSteps]Popup_Alert_On
	$record.Sample:=[LotSteps]Sample
	$record.IN_Oper:=[LotSteps]IN_Oper
	$record.IN_Par1:=[LotSteps]IN_Par1
	$record.OUT_Par1:=[LotSteps]OUT_Par1
	$record.Step_Alert:=[LotSteps]Step_Alert
	$record.Planned_hrs:=[LotSteps]Planned_hrs
	$record.P_test_time:=[LotSteps]P_test_time
	$record.Step_Area:=[LotSteps]Step_Area
	$record.Ar_month:=[LotSteps]Ar_month
	$record.Customer:=[LotSteps]Customer
	$record.Device:=[LotSteps]Device
	$record.Ar_year:=[LotSteps]Ar_year
	$record.Delay_fmt0:=[LotSteps]Delay_fmt0
	$record.DelayStep:=[LotSteps]DelayStep
	$record.Step_Accyld:=[LotSteps]Step_Accyld
	$record.MissingOrExcluded:=[LotSteps]MissingOrExcluded
	$record.Comment2Format:=[LotSteps]Comment2Format
	$record.Temperature:=[LotSteps]Temperature
	$record.Division:=[LotSteps]Division
	$record.Temp_rep_num:=[LotSteps]Temp_rep_num
	$record.Bin11:=[LotSteps]Bin11
	$record.Bin12:=[LotSteps]Bin12
	$record.Bin13:=[LotSteps]Bin13
	$record.Bin14:=[LotSteps]Bin14
	$record.Bin15:=[LotSteps]Bin15
	$record.Bin16:=[LotSteps]Bin16
	$record.Bin17:=[LotSteps]Bin17
	$record.Bin18:=[LotSteps]Bin18
	$record.Bin19:=[LotSteps]Bin19
	$record.Bin20:=[LotSteps]Bin20
	$record.Bin21:=[LotSteps]Bin21
	$record.Bin22:=[LotSteps]Bin22
	$record.Bin23:=[LotSteps]Bin23
	$record.Bin24:=[LotSteps]Bin24
	$record.Bin25:=[LotSteps]Bin25
	$record.Bin26:=[LotSteps]Bin26
	$record.Bin27:=[LotSteps]Bin27
	$record.Bin28:=[LotSteps]Bin28
	$record.Bin29:=[LotSteps]Bin29
	$record.Bin30:=[LotSteps]Bin30
	$record.Bin31:=[LotSteps]Bin31
	$record.Bin32:=[LotSteps]Bin32
	$record.EnableBins:=[LotSteps]EnableBins
	$record.Property:=[LotSteps]Property
	$record.Seq_Number:=[LotSteps]Seq_Number
	$record.STEPBOMResolutionCode:=[LotSteps]STEPBOMResolutionCode
	$record.RelatedLotData:=[LotSteps]RelatedLotData
	$record.StartSetup:=[LotSteps]StartSetup
	$record.SetupStart:=[LotSteps]SetupStart
	$record.SetupEnd:=[LotSteps]SetupEnd
	$record.AccStepDesc:=[LotSteps]AccStepDesc
	$record.AccStepCharge:=[LotSteps]AccStepCharge
	$record.AccItemNumber:=[LotSteps]AccItemNumber
	$record.AccInQty:=[LotSteps]AccInQty
	$record.AccOutQty:=[LotSteps]AccOutQty
	$record.AccHoursSpent:=[LotSteps]AccHoursSpent
	$record.NextStepArea:=[LotSteps]NextStepArea
	$record.QtyintoNextArea:=[LotSteps]QtyintoNextArea
	$record.WaitingHours:=[LotSteps]WaitingHours
	$record.CreationDateTimeStamp:=[LotSteps]CreationDateTimeStamp
	$record.RelatedLotID:=[LotSteps]RelatedLotID
	$record.DateTimeStamp:=[LotSteps]DateTimeStamp
	$record.UniqueID:=[LotSteps]UniqueID
	$record.PunchOutDTStamp:=[LotSteps]PunchOutDTStamp
	$record.PunchInDTStamp:=[LotSteps]PunchInDTStamp
	$record.OSP_Name:=[LotSteps]OSP_Name
	$record.PlannedStartDT:=[LotSteps]PlannedStartDT
	$record.PlannedStopDT:=[LotSteps]PlannedStopDT
	$record.ProgressBar:=[LotSteps]ProgressBar
	$record.DocumentsinDocServer:=[LotSteps]DocumentsinDocServer
	$record.SavedBinningDef:=[LotSteps]SavedBinningDef
	$record.OneID:=[LotSteps]OneID
	$record.Comment1Format:=[LotSteps]Comment1Format
	$record.RejectedByQA:=[LotSteps]RejectedByQA
	
	$records.push($record)
	NEXT RECORD:C51([LotSteps])
End while 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("lotsteps_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | lotSteps: "+String:C10($records.length))
