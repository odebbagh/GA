property workingRange : Collection
property maxSimultany : Integer
property ranges : Collection

singleton Class constructor
	
	This:C1470.workingRange:=New collection:C1472
	This:C1470.maxSimultany:=0
	This:C1470.ranges:=New collection:C1472
	
Function draw($ranges : Collection)->$pict : Picture
	
	This:C1470._rangesToWorkingRanges($ranges)
	$heightPict:=42
	$quarterSize:=6
	$refSVG:=SVG_New(96*$quarterSize; $heightPict)
	
	
	If (This:C1470.workingRange.length=96)
		$vOffset:=12
		$barHeightMax:=($heightPict-$vOffset)\This:C1470.maxSimultany
		For ($s; 0; This:C1470.maxSimultany-1)
			$current:=0
			$start:=-1
			$end:=-1
			For ($q; 0; 95)
				If (This:C1470.workingRange[$q].length<($s+1)) || (This:C1470.workingRange[$q][$s]#$current)
					If ($start=-1)
						If (This:C1470.workingRange[$q].length<($s+1))
						Else 
							$start:=$q
							$current:=This:C1470.workingRange[$q][$s]
						End if 
					Else 
						$end:=$q
						$barHeight:=$barHeightMax
						$barTop:=$vOffset
						$color:=Form:C1466.sfw.shadesGetColors($current)
						Case of 
							: ($current=1)
								$barTop:=11
								$barHeight:=11
						End case 
						$refRect:=SVG_New_rect($refSVG; \
							$start*$quarterSize; \
							$barTop; \
							($end-$start)*$quarterSize; \
							$barHeight; \
							0; 0; $color; $color; 0)
						$range:=This:C1470.ranges[$current-2]
						SVG_SET_ID($refRect; $range.UUID)
						Case of 
							: (This:C1470.workingRange[$q].length<($s+1))
								$start:=-1
							: (This:C1470.workingRange[$q][$s]=0)
								$start:=-1
							Else 
								$start:=$q
						End case 
						$end:=-1
						If (This:C1470.workingRange[$q].length<($s+1))
							$current:=0
						Else 
							$current:=This:C1470.workingRange[$q][$s]
						End if 
					End if 
				End if 
			End for 
			$vOffset+=$barHeightMax
		End for 
	Else 
		//While (this.workingRange.length>0)
		//$start:=this.workingRange.shift()/900
		//$end:=this.workingRange.shift()/900
		//$refRect:=SVG_New_rect($refSVG; \
			$start*$quarterSize; \
			0; \
			($end-$start)*$quarterSize; \
			22; \
			0; 0; "cyan"; "cyan"; 0)
		//SVG_SET_ID($refRect; String($start)+"-"+String($end))
		//End while 
	End if 
	
	For ($h; 1; 23)
		$refRect:=SVG_New_line($refSVG; \
			$h*4*$quarterSize; \
			16; \
			$h*4*$quarterSize; \
			42; \
			"black"; 0.5)
		$refText:=SVG_New_text($refSVG; String:C10($h); \
			$h*4*$quarterSize; \
			1; \
			"Helvetica"; 9; Plain:K14:1; 3; "Black")
	End for 
	For ($q; 1; 95)
		$refRect:=SVG_New_line($refSVG; \
			$q*$quarterSize; \
			28; \
			$q*$quarterSize; \
			42; \
			"grey"; 0.5)
	End for 
	SVG EXPORT TO PICTURE:C1017($refSVG; $pict)
	SVG_CLEAR($refSVG)
	
	
Function _rangesToWorkingRanges($ranges : Collection)
	This:C1470.maxSimultany:=0
	For each ($range; $ranges)
		$qStart:=$range.start\(15*60)
		$qEnd:=$range.end\(15*60)-1
		$range.nbQ:=$qEnd-$qStart
	End for each 
	This:C1470.ranges:=$ranges.orderBy("nbQ desc")
	
	For ($q; 0; 95)
		This:C1470.workingRange[$q]:=New collection:C1472
	End for 
	$r:=1
	For each ($range; This:C1470.ranges)
		$r+=1
		$qStart:=$range.start\(15*60)
		$qEnd:=$range.end\(15*60)-1
		$lenghtMax:=0
		For ($q; $qStart; $qEnd)
			If (This:C1470.workingRange[$q].length>$lenghtMax)
				$lenghtMax:=This:C1470.workingRange[$q].length
			End if 
		End for 
		For ($q; $qStart; $qEnd)
			For ($l; 1; $lenghtMax-This:C1470.workingRange[$q].length)
				This:C1470.workingRange[$q].push(0)
			End for 
			This:C1470.workingRange[$q].push($r)
			If (This:C1470.workingRange[$q].length>This:C1470.maxSimultany)
				This:C1470.maxSimultany:=This:C1470.workingRange[$q].length
			End if 
		End for 
	End for each 