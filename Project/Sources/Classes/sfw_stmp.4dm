property monthNames : Collection
property dayNames : Collection
property originDate : Date
property precisionSeconds : Integer


shared singleton Class constructor
	
	This:C1470.originDate:=!2003-01-01!
	This:C1470.precisionSeconds:=Storage:C1525.stmp.precisionSeconds || 1
	
	This:C1470.monthNames:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.months"; "January;Febuary;March;April;May;June;July;August;September;October;November;December"); ";").copy(ck shared:K85:29)
	This:C1470.dayNames:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.days"; "Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday"); ";").copy(ck shared:K85:29)
	
	//MARK:- stmp build
Function now()->$stmp : Integer
	$stmp:=This:C1470.build(Current date:C33; Current time:C178)
	
	
Function build($date : Date; $time : Time)->$stmp : Integer
	var $dateRef : Date
	var $timeRef : Time
	var $day_s; $time_s : Integer
	
	Case of 
		: (Count parameters:C259=0)
			$dateRef:=Current date:C33()
			$timeRef:=Current time:C178()
		: (Count parameters:C259=1)
			$dateRef:=$date
			$timeRef:=Current time:C178()
		: (Count parameters:C259=2)
			$dateRef:=$date
			$timeRef:=$time
	End case 
	
	$time_s:=($timeRef+0)\This:C1470.precisionSeconds
	$day_s:=($dateRef-This:C1470.originDate)*(86400\This:C1470.precisionSeconds)
	$stmp:=$day_s+$time_s
	
	
Function getMonday($fromDate : Variant)->$monday : Variant
	var $date : Date
	
	If (Count parameters:C259=0)
		$fromDate:=Current date:C33
	End if 
	
	Case of 
		: (Value type:C1509($fromDate)=Is date:K8:7)
			$monday:=$fromDate+(2-Day number:C114($fromDate))
			
		: (Value type:C1509($fromDate)=Is longint:K8:6)
			$date:=This:C1470.getDate($fromDate)
			$monday:=This:C1470.build($date+(2-Day number:C114($date)); ?00:00:00?)
	End case 
	
	//Mark:- Week functions
	
Function getWeekNum($param : Variant)->$num : Integer
/*Le numéro de la semaine est calculé comme défini dans ISO 8601
la manière officielle de le faire en Europe. Selon le standard, la première semaine de l'année est une semaine avec le premier mardi de l'année ou qui contient le 4 janvier. 
Avec cette méthode, le 1er, le 2 et le 3 janvier peuvent être inclus dans la dernière semaine de l'année précédente, ou le 29, le 30 et le 31 décembre peuvent être inclus dans la première semaine de l'année suivante.
*/
	
	Case of 
		: (Value type:C1509($param)=Is longint:K8:6)
			$date:=This:C1470.getDate($param)
		: (Value type:C1509($param)=Is date:K8:7)
			$date:=$param
	End case 
	
	$year:=Year of:C25($date)
	$4thJan:=Add to date:C393(!00-00-00!; $year; 1; 4)
	$mondayOfDate:=$date-((Day number:C114($date)+5)%7)
	$thrusdaySameWeek:=Add to date:C393($mondayOfDate; 0; 0; 3)
	$firstMonday:=$4thJan-((Day number:C114($4thJan)+5)%7)
	$num:=(($thrusdaySameWeek-$firstMonday)\7)+1
	If ($num=0)
		$num:=53
	End if 
	
Function getMondayOfAWeek($year : Integer; $weekNum : Integer)->$monday : Date
	$4thJan:=Add to date:C393(!00-00-00!; $year; 1; 4)
	$mondayOfDate:=$4thJan-((Day number:C114($4thJan)+5)%7)
	$thrusdaySameWeek:=Add to date:C393($mondayOfDate; 0; 0; 3)
	$firstMonday:=$4thJan-((Day number:C114($4thJan)+5)%7)
	$num:=(($thrusdaySameWeek-$firstMonday)\7)+1
	$monday:=$firstMonday+(7*($weekNum-$num))
	
	
	//MARK:-Get Date & Time
	
Function getDate($stmp : Integer; $dontDisplay0 : Boolean)->$date : Date
	var $nbDays : Integer
	If ($stmp=0) && ($dontDisplay0)
		$date:=!00-00-00!
	Else 
		$nbDays:=$stmp\86400*This:C1470.precisionSeconds
		$date:=This:C1470.originDate+($nbDays)
	End if 
	
Function getTime($stmp : Integer)->$time : Time
	
	var $s; $m; $h : Integer
	$stmp:=$stmp*This:C1470.precisionSeconds
	$s:=($stmp%60)
	$m:=($stmp\60)%60
	$h:=($stmp\3600)%24
	
	$time:=Time:C179(String:C10($h; "00")+":"+String:C10($m; "00")+":"+String:C10($s; "00"))
	
Function getTimeInSec($stmp : Integer)->$nbSecondes : Integer
	
	$stmp:=$stmp*This:C1470.precisionSeconds
	$seconde:=$stmp%60
	$Minute:=(Int:C8($stmp))%60
	$heure:=(Int:C8($stmp/3600))%24
	$nbSecondes:=((($heure*60)+$minute)*60)+$seconde
	
Function getStmpTruncMin($stmp : Integer)->$stmpMin : Integer
	
	$stmp:=$stmp*This:C1470.precisionSeconds
	$seconde:=$1%60
	
	$stmpMin:=$stmp-$seconde
	
Function getNbMinutes($stmp : Integer)->$nbMinutes : Integer
	
	$nbMinutes:=$stmp*This:C1470.precisionSeconds\60
	
Function getRelativeDuration($duration : Integer; $nbSegments : Integer)->$answer : Text
	
	
	If (Count parameters:C259>1)
		$nb_Segment_max:=$nbSegments
	Else 
		$nb_Segment_max:=2
	End if 
	$answer:=""
	
	$continue:=True:C214
	$nb_segment:=0
	$jour:=True:C214
	$heure:=True:C214
	$minute:=True:C214
	While ($continue)
		Case of 
			: ($duration>(23*60*60\This:C1470.precisionSeconds)) & ($jour)
				$nb_jour:=$duration\(24*60*60\This:C1470.precisionSeconds)
				If ($nb_jour=0)
					$jour:=False:C215
				Else 
					$answer:=$answer+String:C10($nb_jour)+" j "
					$nb_segment:=$nb_segment+1
				End if 
				$duration:=$duration-($nb_jour*(24*60*60\This:C1470.precisionSeconds))
			: ($duration>(59*60\This:C1470.precisionSeconds)) & ($heure)
				$nb_heure:=$duration\(60*60\This:C1470.precisionSeconds)
				If ($nb_heure=0)
					$heure:=False:C215
				Else 
					$answer:=$answer+String:C10($nb_heure)+" h "
					$nb_segment:=$nb_segment+1
				End if 
				$duration:=$duration-($nb_heure*(60*60\This:C1470.precisionSeconds))
			: ($duration>(59\This:C1470.precisionSeconds)) & ($minute)
				$nb_min:=$duration\(60\This:C1470.precisionSeconds)
				If ($nb_min=0)
					$minute:=False:C215
				Else 
					$answer:=$answer+String:C10($nb_min)+" min "
					$nb_segment:=$nb_segment+1
				End if 
				$duration:=$duration-($nb_min*60\This:C1470.precisionSeconds)
			Else 
				$answer:=$answer+String:C10($duration)+" sec "
				$duration:=0
				$nb_segment:=$nb_segment+1
		End case 
		
		If ($nb_segment>=$nb_Segment_max) | ($duration=0)
			$continue:=False:C215
			
		End if 
	End while 
	$answer:=cs:C1710.sfw_string.me.trimSpace($answer)
	If ($answer="")
		$answer:="-"
	End if 
	
	
Function getRelativeDay($date : Date)->$result : Text
	
	$result:=""
	Case of 
		: ($date=Current date:C33)
			$result:=Localized string:C991("dateAndTime.today")
		: ($date=(Current date:C33-1))
			$result:=Localized string:C991("dateAndTime.yesterday")
		: ($date=(Current date:C33-2))
			$result:=Localized string:C991("dateAndTime.beforeyesterday")
		: ($date=(Current date:C33+1))
			$result:=Localized string:C991("dateAndTime.tomorrow")
		: ($date=(Current date:C33+2))
			$result:=Localized string:C991("dateAndTime.aftertomorrow")
		: ($date>(Current date:C33-7)) & ($date<(Current date:C33-2))
			$jour:=Day number:C114($date)
			$days:=Split string:C1554(Localized string:C991("dateAndTime.days"); ";")
			$result:=$days[$jour-1]
			
			
		: ($date<(Current date:C33+7)) & ($date>(Current date:C33+2))
			$jour:=Day number:C114($date)
			$days:=Split string:C1554(Localized string:C991("dateAndTime.nextdays"); ";")
			$result:=$days[$jour-1]
			
		Else 
			$result:=String:C10($date; System date abbreviated:K1:2)
	End case 
	
	
Function getRelativeDate($stmp : Integer)->$result : Text
	
	var $date : Date
	
	$date:=This:C1470.getDate($stmp)
	$result:=This:C1470.getRelativeDay($date)
	
	
Function getFullRelative($stmp : Integer)->$answer : Text
	
	$answer:=""
	$now:=This:C1470.now()
	Case of 
		: ($now=$stmp)
			$answer:="now"
		: ($now-$stmp<(24*60*60\This:C1470.precisionSeconds))
			$answer:=This:C1470.getRelativeDuration($now-$stmp; 1)
		Else 
			$answer:=This:C1470.getRelativeDate($stmp)
	End case 
	
	
Function getEaster($year : Integer)->$easter : Date
	var $nombre_or : Integer
	var $pseudo_epacte : Integer
	var $i; $j : Integer
	var $month : Integer
	var $day : Integer
	var $century : Integer
	
	
	$nombre_or:=$year%19
	$century:=$year\100
	$pseudo_epacte:=($century-($century\4)-(((8*$century)+13)\25)+(19*$nombre_or)+15)%30
	$i:=$pseudo_epacte-(($pseudo_epacte\28)*(1-(($pseudo_epacte\28)*(29\($pseudo_epacte+1))*((21-$nombre_or)\11))))
	
	$j:=($year+($year\4)+$i+2-$century+($century\4))%7
	$L:=$i-$j
	$month:=3+(($L+40)\44)
	$day:=$L+28-(31*($month\4))
	$year:=$year-2001
	$month:=$month-1
	$day:=$day-1
	$easter:=Add to date:C393(!2001-01-01!; $year; $month; $day)
	
	
	
Function getNthWeekday($year : Integer; $month : Integer; $nth : Integer; $weekday : Integer)->$targetDate : Date
	
	var $firstDayOfMonth : Date
	var $firstWeekday : Integer
	var $dayOffset : Integer
	
	$firstDayOfMonth:=Add to date:C393(!00-00-00!; $year; $month; 1)
	
	$firstWeekday:=Day number:C114($firstDayOfMonth)
	
	If ($firstWeekday<=$weekday)
		$dayOffset:=$weekday-$firstWeekday
	Else 
		$dayOffset:=7-($firstWeekday-$weekday)
	End if 
	$targetDate:=$firstDayOfMonth+$dayOffset+(($nth-1)*7)
	
	If (Month of:C24($targetDate)>$month)
		$targetDate:=This:C1470.getLastWeekday($year; $month; $weekday)
	End if 
	
	
	
Function getLastWeekday($year : Integer; $month : Integer; $weekday : Integer)->$targetDate : Date
	
	var $lastDayOfMonth : Date
	var $lastWeekday : Integer
	var $dayOffset : Integer
	
	
	$lastDayOfMonth:=Add to date:C393(!00-00-00!; $year; $month+1; 1)
	$lastWeekday:=Day number:C114($lastDayOfMonth)
	
	If ($lastWeekday>=$weekday)
		$dayOffset:=$lastWeekday-$weekday
	Else 
		$dayOffset:=7-($weekday-$lastWeekday)
	End if 
	
	$targetDate:=$lastDayOfMonth-$dayOffset
	
Function getIslamiqueDay($refDate : Date; $year : Integer)->$targetdate : Date
	
	$DaysToSubtract:=11
	$YearDifference:=$year-Year of:C25($refDate)
	If ($YearDifference%2=0)
		$delta:=Int:C8($YearDifference*$DaysToSubtract)+1
	Else 
		$delta:=Int:C8($YearDifference*$DaysToSubtract)
	End if 
	
	$targetdate:=Add to date:C393($refDate-$delta; $YearDifference; 0; 0)
	
Function getDaysCounter($date : Date)->$nbdays : Text
	
	$deference:=cs:C1710.sfw_stmp.me.build(Current date:C33())-cs:C1710.sfw_stmp.me.build($date)
	$sign:="-"
	If ($deference<0)
		$deference*=(-1)
		$sign:=""
	End if 
	$nbdays:=$sign+cs:C1710.sfw_stmp.me.getRelativeDuration($deference; 2)
	
	
	
Function getHour($stmp : Integer)->$hour : Integer
	
	If (Count parameters:C259=0)
		$stmp:=This:C1470.now()
	End if 
	
	$hour:=$stmp%(3600*24)\3600
	
	
Function queryFunction($storageAttribute : Text; $event : Object)->$result : Object
	var $date : Variant
	$operator:=$event.operator
	$parameters:=New collection:C1472
	Case of 
		: ($operator="==")
			$date:=$event.value
			$query:=$storageAttribute+" >= :1 AND "+$storageAttribute+" < :2"
			Case of 
				: (Value type:C1509($date)=Is date:K8:7)
					$parameters.push(cs:C1710.sfw_stmp.me.build($date; ?00:00:00?))
					$parameters.push(cs:C1710.sfw_stmp.me.build($date+1; ?00:00:00?))
				: (Value type:C1509($date)=Is text:K8:3)
					If ("@"=Substring:C12($date; 1; 1))
						$date:=Substring:C12($date; 2)
					End if 
					If ("@"=Substring:C12($date; Length:C16($date); 1))
						$date:=Substring:C12($date; 1; Length:C16($date)-1)
					End if 
					Case of 
						: (Length:C16($date)=4) && (String:C10(Num:C11($date))=$date)
							$year:=Num:C11($date)
							$parameters.push(cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; $year; 1; 1); ?00:00:00?))
							$parameters.push(cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; $year; 12; 31); ?00:00:00?))
						: (Length:C16($date)=2) && (String:C10(Num:C11($date))=$date)
							$year:=Num:C11($date)
							If ($year+2000>Year of:C25(Current date:C33))
								$year+=1900
							Else 
								$year+=2000
							End if 
							$parameters.push(cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; $year; 1; 1); ?00:00:00?))
							$parameters.push(cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; $year; 12; 31); ?00:00:00?))
					End case 
			End case 
			
		: ($operator=">")
			$date:=$event.value
			$query:=$storageAttribute+" > :1"
			$parameters.push(cs:C1710.sfw_stmp.me.build($date; ?00:00:00?))
			
		: ($operator=">=")
			$date:=$event.value
			$query:=$storageAttribute+" >= :1"
			$parameters:=New collection:C1472
			$parameters.push(cs:C1710.sfw_stmp.me.build($date; ?00:00:00?))
			
		: ($operator="<")
			$date:=$event.value
			$query:=$storageAttribute+" < :1"
			$parameters.push(cs:C1710.sfw_stmp.me.build($date; ?00:00:00?))
			
		: ($operator="<=")
			$date:=$event.value
			$query:=$storageAttribute+" <= :1"
			$parameters.push(cs:C1710.sfw_stmp.me.build($date; ?00:00:00?))
			
		: ($operator="!=")
			$date:=$event.value
			$query:="NOT("+$storageAttribute+" >= :1 AND "+$storageAttribute+" < :2)"
			$parameters.push(cs:C1710.sfw_stmp.me.build($date; ?00:00:00?))
			$parameters.push(cs:C1710.sfw_stmp.me.build($date+1; ?00:00:00?))
			
		: ($operator="IN")
			$queryParts:=New collection:C1472
			$p:=0
			For each ($date; $event.value)
				$queryParts.push("( "+$storageAttribute+" >= :"+String:C10($p+1)+" AND "+$storageAttribute+" < :"+String:C10($p+2)+" )")
				$parameters.push(cs:C1710.sfw_stmp.me.build($date; ?00:00:00?))
				$parameters.push(cs:C1710.sfw_stmp.me.build($date+1; ?00:00:00?))
				$p+=2
			End for each 
			$query:=$queryParts.join(" OR ")
			
	End case 
	$result:=New object:C1471
	$result.query:=$query
	$result.parameters:=$parameters