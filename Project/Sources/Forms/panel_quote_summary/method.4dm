var $computeStatistiques : Boolean:=False:C215
var $graph : cs:C1710.sfw_chart_bar
var $emptyPict : Picture

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		$computeStatistiques:=True:C214
		
		
	: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
		$computeStatistiques:=True:C214
		
		
End case 


If ($computeStatistiques)
	Form:C1466.barIncorporations:=$emptyPict
	
	If (Form:C1466.sfw.lb_items#Null:C1517)
		
		$graph:=cs:C1710.sfw_chart_bar.new()
		$graph.title.height:=20
		
		OBJECT GET SUBFORM CONTAINER SIZE:C1148($panelWidth; $panelHeight)
		OBJECT GET COORDINATES:C663(*; "barIncorporations"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "barIncorporations"; $g; $h; $panelWidth-($g*2); $b)
		$graphWidth:=$panelWidth-($g*2)
		$graphHeight:=$b-$h
		
		$incorporations:=Form:C1466.sfw.lb_items.distinct("dateCreation"; ck count values:K85:37)
		If ($incorporations.length>0)
			
			For each ($incorporation; $incorporations)
				$incorporation.value:=Date:C102($incorporation.value)
				
			End for each 
			$incorporations:=$incorporations.orderBy("value")
			$yearMin:=Year of:C25($incorporations.min("value"))
			$yearMax:=Year of:C25($incorporations.max("value"))
			$monthMin:=Month of:C24($incorporations.min("value"))
			$monthMax:=Month of:C24($incorporations.max("value"))
			
			Form:C1466.incorporationDateData:=New collection:C1472
			Case of 
				: ($yearMin#$yearMax)
					$graph.title.text:="Nb of quotes per year ("+String:C10($yearMin)+"-"+String:C10($yearMax)+")"
					For ($year; $yearMin; $yearMax)
						Form:C1466.incorporationDateData.push({xValue: Form:C1466.incorporationDateData.length+1; xLabel: String:C10($year); year: $year; yValue: 0})
					End for 
					If (Form:C1466.incorporationDateData.length>1)
						For each ($incorporation; $incorporations)
							$year:=Year of:C25($incorporation.value)
							$item:=Form:C1466.incorporationDateData.query("year = :1"; $year).first()
							$item.yValue+=$incorporation.count
						End for each 
					End if 
				: ($monthMin#$monthMax)
					$graph.title.text:="Nb of quotes for "+String:C10($yearMin)+" (Jan-Dec)"
					For ($month; 1; 12)
						Form:C1466.incorporationDateData.push({xValue: Form:C1466.incorporationDateData.length+1; xLabel: String:C10($month)+"-"+String:C10($yearMin); year: $yearMin; month: $month; yValue: 0})
					End for 
					If (Form:C1466.incorporationDateData.length>1)
						For each ($incorporation; $incorporations)
							$year:=Year of:C25($incorporation.value)
							$month:=Month of:C24($incorporation.value)
							$item:=Form:C1466.incorporationDateData.query("year = :1 & month = :2"; $year; $month).first()
							$item.yValue+=$incorporation.count
						End for each 
						
					End if 
			End case 
			
			If (Form:C1466.incorporationDateData.length>1)
				
				$graph.values:=Form:C1466.incorporationDateData
				$graph.setAreaSize($graphWidth; $graphHeight)
				$graph.xAxis.alignLabel:=Align center:K42:3
				Form:C1466.barIncorporations:=$graph.drawGraph()
				
			End if 
		End if 
	End if 
End if 