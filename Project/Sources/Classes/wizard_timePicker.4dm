singleton Class constructor
	
	
	//mark:- Interface
	
Function formMethod()
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			
			Form:C1466.time:=New object:C1471
			Form:C1466.time.display:=New object:C1471
			Form:C1466.time.display.timeStamp:=cs:C1710.sfw_stmp.me.getTime(Form:C1466.timeStamp)
			This:C1470.wizard_timePicker_init()
			
			
		Else 
			
			
	End case 
	
	
Function getTime()
	
	If (Form:C1466.pm=1)
		$hour:=String:C10(12+Num:C11(Form:C1466.hour))
		
	Else 
		$hour:=Num:C11(Form:C1466.hour)<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.hour))) : String:C10(Num:C11(Form:C1466.hour))
		
	End if 
	$time:=String:C10("?"+$hour+":"+Form:C1466.minute+":"+"00?"; HH MM AM PM:K7:5)
	Form:C1466.timeStamp:=cs:C1710.sfw_stmp.me.build(!00-00-00!; Time:C179($time))
	//Form.timeStamp:=Form.time.display.timeStamp
	//Form.time.display.hour:=Form.hour
	//Form.time.display.hour:=Form.minute
	//Form.time.display.pm:=Form.pm
	//Form.time.display.am:=Form.am
	
Function wizard_timePicker_init()
	
	Form:C1466.hour:=String:C10(cs:C1710.sfw_stmp.me.getHour(Form:C1466.time.display.timeStamp))
	$hour:=Num:C11(Form:C1466.hour)<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.hour))) : String:C10(Num:C11(Form:C1466.hour))
	Form:C1466.hour:=$hour
	Form:C1466.minute:=String:C10(cs:C1710.sfw_stmp.me.getNbMinutes(Form:C1466.time.display.timeStamp)%60)
	$minute:=Num:C11(Form:C1466.minute)<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.minute))) : String:C10(Num:C11(Form:C1466.minute))
	Form:C1466.minute:=$minute
	
	Case of 
			
		: (Num:C11(Form:C1466.hour)=0)
			Form:C1466.hour:="12"
			
		: (Num:C11(Form:C1466.hour)>12)
			Form:C1466.hour:=String:C10(Num:C11(Form:C1466.hour)%12)
			$hour:=Num:C11(Form:C1466.hour)<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.hour))) : String:C10(Num:C11(Form:C1466.hour))
			Form:C1466.hour:=$hour
			If (Num:C11(Form:C1466.hour)=0)
				Form:C1466.hour:="12"
			End if 
			Form:C1466.pm:=1
			Form:C1466.am:=0
		Else 
			
			If (Num:C11(Form:C1466.hour)#0)
				Form:C1466.am:=1
				Form:C1466.pm:=0
			End if 
			
	End case 
	
	
Function bMinutePlus()
	
	If (Num:C11(Form:C1466.minute)<59)
		$minute:=Num:C11(Form:C1466.minute)+1<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.minute)+1)) : String:C10(Num:C11(Form:C1466.minute)+1)
		Form:C1466.minute:=$minute
		
	Else 
		
		If (Num:C11(Form:C1466.minute)=59)
			
			This:C1470.bHourPlus()
			Form:C1466.minute:="00"
		Else 
			
		End if 
		
	End if 
	
	
Function bMinuteMinus()
	
	If (Num:C11(Form:C1466.minute)>0)
		$minute:=Num:C11(Form:C1466.minute)-1<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.minute)-1)) : String:C10(Num:C11(Form:C1466.minute)-1)
		Form:C1466.minute:=$minute
		
	Else 
		
		If (Num:C11(Form:C1466.minute)=0)
			
			This:C1470.bHourMinus()
			Form:C1466.minute:="59"
		Else 
			
		End if 
		
	End if 
	
	
Function bHourPlus()
	
	If (Num:C11(Form:C1466.hour)<12)
		$hour:=Num:C11(Form:C1466.hour)+1<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.hour)+1)) : String:C10(Num:C11(Form:C1466.hour)+1)
		Form:C1466.hour:=$hour
		
	Else 
		Form:C1466.hour:="01"
	End if 
	
	
Function bHourMinus()
	
	
	If (Num:C11(Form:C1466.hour)>1)
		$hour:=Num:C11(Form:C1466.hour)-1<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.hour)-1)) : String:C10(Num:C11(Form:C1466.hour)-1)
		Form:C1466.hour:=$hour
		
	Else 
		
		If (Num:C11(Form:C1466.hour)=1)
			Form:C1466.hour:="12"
			
		Else 
			
		End if 
		
	End if 
	
	
Function bNow()
	
	Form:C1466.time.display.timeStamp:=cs:C1710.sfw_stmp.me.getTime(Current time:C178())
	
	Form:C1466.hour:=String:C10(cs:C1710.sfw_stmp.me.getHour(Form:C1466.time.display.timeStamp))
	
	If (Num:C11(Form:C1466.hour)>12)
		Form:C1466.hour:=String:C10(Num:C11(Form:C1466.hour)%12)
		Form:C1466.pm:=1
		Form:C1466.am:=0
	Else 
		Form:C1466.am:=1
		Form:C1466.pm:=0
	End if 
	
	$hour:=Num:C11(Form:C1466.hour)<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.hour))) : String:C10(Num:C11(Form:C1466.hour))
	Form:C1466.hour:=$hour
	Form:C1466.minute:=String:C10(cs:C1710.sfw_stmp.me.getNbMinutes(Form:C1466.time.display.timeStamp)%60)
	$minute:=Num:C11(Form:C1466.minute)<10 ? String:C10("0"+String:C10(Num:C11(Form:C1466.minute))) : String:C10(Num:C11(Form:C1466.minute))
	Form:C1466.minute:=$minute
	
	Form:C1466.second:=String:C10(cs:C1710.sfw_stmp.me.getTimeInSec(Form:C1466.time.display.timeStamp)%60)
	
	
	
Function bClear()
	
	Form:C1466.time.display.timeStamp:=cs:C1710.sfw_stmp.me.getTime(Time:C179("00:00:00"))
	Form:C1466.hour:="00"
	Form:C1466.minute:="00"
	Form:C1466.second:=String:C10(cs:C1710.sfw_stmp.me.getTimeInSec(Form:C1466.time.display.timeStamp)%60)
	Form:C1466.pm:=0
	Form:C1466.am:=0
	
	
	
	
	
	