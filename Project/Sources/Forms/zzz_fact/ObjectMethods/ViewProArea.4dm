var $data : Object


Case of 
	: (FORM Event:C1606.code=On VP Ready:K2:59)
		
		//If (True)
		//$daysOff_MA:=New collection()
		//$start:=Add to date(!00-00-00!; 2023; 12; 31)
		//$end:=Add to date(!00-00-00!; 2024; 12; 31)
		//$daysOff_MA:=New collection()
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 1; 1))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 1; 11))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 4; 10))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 4; 11))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 5; 1))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 7; 30))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 6; 16))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 6; 17))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 7; 8))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 8; 14))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 8; 20))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 8; 21))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 9; 16))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 11; 6))
		//$daysOff_MA.push(Add to date(!00-00-00!; 2024; 11; 18))
		
		//$months:=New object("labels"; Split string("January, February, March, April, May, June, July, August, September, October, November, December"; ","; sk ignore empty strings+sk trim spaces))
		
		//While ($start<=$end)
		//$start:=Add to date($start; 0; 0; 1)
		//If ($months[String(Month of($start))]=Null)
		//$months[String(Month of($start))]:=New object("off"; 0)
		//End if 
		
		//$number:=Day number($start)
		//If ($number=Sunday) || ($number=Saturday)
		//$months[String(Month of($start))].off+=1
		//continue
		//End if 
		
		//If ($daysOff_MA.indexOf($start)#-1)
		//$months[String(Month of($start))].off+=1
		//continue
		//End if 
		//End while 
		
		//$text:=Document to text("projectsPerUser.json")
		//$timesheets:=JSON Parse($text)
		//End if 
		
		
		//$data:=New object()
		//$data.people:=New collection()
		//For each ($person; $timesheets)
		//If ($person="total") || ($person="timelogsCount")
		//continue
		//End if 
		
		
		//$line:=New object()
		//$line.name:=$person
		//For ($i; 1; 12)
		//$days:=Day of(Add to date(Add to date(!00-00-00!; 2024; $i; 1); 0; 0; -1))
		//$line["Ouvres"+String($i)]:=$days-Num($months[String($i)].off)
		//$line["Billable"+String($i)]:=Round(Num($timesheets[$person][String($i)].bill); 2)
		//$line["NonBillable"+String($i)]:=Round(Num($timesheets[$person][String($i)].not_bill); 2)
		//$line["JourTravailles"+String($i)]:=Round(Num($timesheets[$person][String($i)].total); 2)
		
		//$line["facturabilite"+String($i)]:=$line["Ouvres"+String($i)]#0 ? String(Round($line["Billable"+String($i)]/$line["Ouvres"+String($i)]; 2)*100)+"%" : "0%"
		//$line["usabilite"+String($i)]:=$line["Ouvres"+String($i)]#0 ? String(Round($line["JourTravailles"+String($i)]/$line["Ouvres"+String($i)]; 2)*100)+"%" : "0%"
		//End for 
		
		//$data.people.push($line)
		//End for each 
		
		
		//$options:=cs.ViewPro.TableOptions.new()
		//$options.tableColumns:=New collection()
		//$keys:=OB Keys($data.people[0])
		//For each ($key; $keys)
		//$header:=New object()
		//$header.name:=$key
		//$header.dataField:=$key
		//$options.tableColumns.push($header)
		//End for each 
		
		//VP SET DATA CONTEXT("ViewProArea"; $data; $sheetIndex)
		//VP CREATE TABLE(VP Cells("ViewProArea"; 0; 1; $keys.length; $data.people.length); "ContextTable"; "people"; $options)
		//VP COLUMN AUTOFIT(VP Cells("ViewProArea"; 0; 0; $keys.length; 0; $sheetIndex))
		
		
		//$border:=New object("color"; "red"; "style"; vk line style thick)
		//$option:=New object("outline"; True)
		//$style:=New object
		//$style.hAlign:=1
		//$style.font:="14pt Arial"
		//For ($i; 0; 11)
		//VP ADD SPAN(VP Cells("ViewProArea"; 1+($i*6); 0; 6; 0))
		//VP SET BORDER(VP Cells("ViewProArea"; 1+($i*6); 0; 6; $data.people.length+2); $border; $option)
		//VP SET VALUE(VP Cell("ViewProArea"; 1+($i*6); 0); {value: $months.labels[$i]})
		//VP SET CELL STYLE(VP Cell("ViewProArea"; 1+($i*6); 0); $style)
		//End for 
End case 

