property _entry : cs:C1710.sfw_definitionEntry
property _searchbox : Text
property _queryString : Text
property _querySettings : Object
property _queryParts : Collection
property _queryStringParts : Collection
property _notToAdd : Boolean
property _tagToAdd : Text
property _partIndice : Integer
property searchHighlightParts : Collection
property lastSearches : Collection

singleton Class constructor
	
	This:C1470._searchbox:=""
	This:C1470._queryString:=""
	This:C1470._querySettings:=New object:C1471()
	This:C1470._querySettings.parameters:=New object:C1471()
	This:C1470._querySettings.attributes:=New object:C1471()
	This:C1470._querySettings.queryPlan:=False:C215
	This:C1470._querySettings.queryPath:=False:C215
	This:C1470.lastSearches:=New collection:C1472
	
	//MARK:-Analyse the search box
Function _cleanSearchbox()  //to remove useless spaces in content of the searchbox 
	var $last : Object
	
	This:C1470._searchbox:=Split string:C1554(This:C1470._searchbox; " ").join(" "; ck ignore null or empty:K85:5)
	If (This:C1470._searchbox#"")
		$last:=This:C1470.lastSearches.query("entryIdent = :1"; This:C1470._entry.ident).first()
		If (String:C10($last.search)#This:C1470._searchbox)
			$indices:=This:C1470.lastSearches.indices("entryIdent = :1 and search = :2"; This:C1470._entry.ident; This:C1470._searchbox)
			If ($indices.length>0)
				This:C1470.lastSearches.remove($indices[0])
			End if 
			This:C1470.lastSearches.unshift({entryIdent: This:C1470._entry.ident; search: This:C1470._searchbox})
			If (This:C1470.lastSearches.length>10)
				$first:=This:C1470.lastSearches.pop()
			End if 
		End if 
	End if 
	
	
	//MARK:-Build a list of criteria
Function _splitSearchboxInParts()
	
	var $rawSearchbox : Text  //the contents of the search box ready to be eaten character by character
	var $currentValue : Text  //the currentPart build char by char
	var $char : Text  //the current char to analyze
	var $positionNext : Integer  //where is the next char to be process
	var $inDoubleQuotes : Boolean  //to know if we are currently in a double quotes or not
	var $potentialTag : Text  //this value contain the name of the tag, if exist
	This:C1470._queryParts:=New collection:C1472
	$rawSearchbox:=This:C1470._searchbox
	
	$currentValue:=""
	$inDoubleQuotes:=False:C215
	This:C1470._tagToAdd:=""
	This:C1470._notToAdd:=False:C215
	While ($rawSearchbox#"")
		$char:=$rawSearchbox[[1]]
		$positionNext:=2
		Case of 
			: (($rawSearchbox="ET @") || ($rawSearchbox="ET(@")) & Not:C34($inDoubleQuotes) && (Get database localization:C1009(Current localization:K5:22)="fr")
				If (This:C1470._queryParts.length=0)
					This:C1470._pushCurrentValueInParts("et")
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="AND"
					This:C1470._queryParts.push($part)
					This:C1470._notToAdd:=False:C215
				End if 
				$positionNext:=($rawSearchbox="ET @") ? 4 : 3
			: (($rawSearchbox="AND @") || ($rawSearchbox="AND(@")) & Not:C34($inDoubleQuotes)
				If (This:C1470._queryParts.length=0)
					This:C1470._pushCurrentValueInParts("and")
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="AND"
					This:C1470._queryParts.push($part)
					This:C1470._notToAdd:=False:C215
				End if 
				$positionNext:=($rawSearchbox="AND @") ? 5 : 4
			: (($rawSearchbox="& @") || ($rawSearchbox="&(@")) & Not:C34($inDoubleQuotes)
				If (This:C1470._queryParts.length=0)
					This:C1470._pushCurrentValueInParts("&")
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="AND"
					This:C1470._queryParts.push($part)
					This:C1470._notToAdd:=False:C215
				End if 
				$positionNext:=($rawSearchbox="& @") ? 3 : 2
			: (($rawSearchbox="OU @") || ($rawSearchbox="OU(@")) & Not:C34($inDoubleQuotes) && (Get database localization:C1009(Current localization:K5:22)="fr")
				If (This:C1470._queryParts.length=0)
					This:C1470._pushCurrentValueInParts("ou")
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="OR"
					This:C1470._queryParts.push($part)
					This:C1470._notToAdd:=False:C215
				End if 
				$positionNext:=($rawSearchbox="OU @") ? 4 : 3
			: (($rawSearchbox="OR @") || ($rawSearchbox="OR(@")) & Not:C34($inDoubleQuotes)
				If (This:C1470._queryParts.length=0)
					This:C1470._pushCurrentValueInParts("or")
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="OR"
					This:C1470._queryParts.push($part)
					This:C1470._notToAdd:=False:C215
				End if 
				$positionNext:=($rawSearchbox="OR @") ? 4 : 3
			: (($rawSearchbox="| @") || ($rawSearchbox="|(@")) & Not:C34($inDoubleQuotes)
				If (This:C1470._queryParts.length=0)
					This:C1470._pushCurrentValueInParts("|")
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="OR"
					This:C1470._queryParts.push($part)
					This:C1470._notToAdd:=False:C215
				End if 
				$positionNext:=($rawSearchbox="| @") ? 3 : 2
			: ($char="-") & ($currentValue="")
				This:C1470._notToAdd:=True:C214
			: ($rawSearchbox="\\s@")
				$currentValue+=" "
				$positionNext:=3
			: (($char="(") || ($char=")")) & Not:C34($inDoubleQuotes)
				This:C1470._pushCurrentValueInParts($currentValue)
				$currentValue:=""
				This:C1470._pushParenthesisParts($char)
			: ($char="\"")
				This:C1470._pushCurrentValueInParts($currentValue)
				$currentValue:=""
				$inDoubleQuotes:=Not:C34($inDoubleQuotes)
			: ($char=" ") & Not:C34($inDoubleQuotes)
				This:C1470._pushCurrentValueInParts($currentValue)
				$currentValue:=""
			: ($char=":") & Not:C34($inDoubleQuotes)
				$potentialTag:=$currentValue
				$indices:=This:C1470._entry.searchfields.indices("tag = :1 or tags[] = :1"; $potentialTag)
				If ($indices.length>0)
					This:C1470._tagToAdd:=$potentialTag
					$currentValue:=""
				Else 
					$currentValue+=$char
				End if 
			: (Position:C15($char; "<>#="; *)>0)
				$potentialTag:=$currentValue
				$indices:=This:C1470._entry.searchfields.indices("tag = :1 or tags[] = :1"; $potentialTag)
				If ($indices.length>0)
					This:C1470._tagToAdd:=$potentialTag
					$currentValue:=$char
					If ($rawSearchbox=($char+"=@"))
						$currentValue+="="
						$positionNext:=3
					Else 
						$positionNext:=2
					End if 
				Else 
					$currentValue+=$char
				End if 
			Else 
				$currentValue+=$char
		End case 
		$rawSearchbox:=Substring:C12($rawSearchbox; $positionNext)
	End while 
	This:C1470._pushCurrentValueInParts($currentValue)
	This:C1470._completeImpliciteOperator()
	
Function _pushCurrentValueInParts($currentValue : Text)
	var $part : 4D:C1709.Object
	
	$part:=(This:C1470._notToAdd) ? New object:C1471("not"; True:C214) : New object:C1471
	Case of 
		: ($currentValue="")
		: (This:C1470._tagToAdd#"")
			$part.type:="value"
			$part.tag:=This:C1470._tagToAdd
			$part.value:=$currentValue
			This:C1470._queryParts.push($part)
			This:C1470._tagToAdd:=""
			This:C1470._notToAdd:=False:C215
		Else 
			$part.type:="value"
			$part.value:=$currentValue
			This:C1470._queryParts.push($part)
			This:C1470._notToAdd:=False:C215
	End case 
	
Function _pushParenthesisParts($char : Text)
	var $parenthesisPart : Object
	
	$parenthesisPart:=(This:C1470._notToAdd) && ($char="(") ? New object:C1471("not"; True:C214) : New object:C1471
	This:C1470._notToAdd:=False:C215
	$parenthesisPart.type:="parenthesis"
	$parenthesisPart.value:=$char
	This:C1470._queryParts.push($parenthesisPart)
	
	//MARK:-Consolidate the list of criteria
	
Function _completeImpliciteOperator()
	
	var $previousPart; $part : Object
	var $queryPartsIN : Collection
	var $nbParentheses : Integer
	
	$queryPartsIN:=This:C1470._queryParts  //  copy the content of the current collection ...
	This:C1470._queryParts:=New collection:C1472  // ... before reset this collection for a full rebuild
	$previousPart:=Null:C1517
	For each ($part; $queryPartsIN)
		Case of 
			: ($previousPart.type="value") & ($part.type="value")
				This:C1470._pushANDOperator()
			: ($previousPart.type="parenthesis") & ($previousPart.value=")") & ($part.type="value")
				This:C1470._pushANDOperator()
			: ($previousPart.type="parenthesis") & ($previousPart.value=")") & ($part.type="parenthesis") & ($part.value="(")
				This:C1470._pushANDOperator()
				$nbParentheses+=1
			: ($previousPart.type="value") & ($part.type="parenthesis") & ($part.value="(")
				This:C1470._pushANDOperator()
				$nbParentheses+=1
			: ($part.type="parenthesis") & ($part.value="(")
				$nbParentheses+=1
			: ($part.type="parenthesis") & ($part.value=")")
				$nbParentheses-=1
		End case 
		This:C1470._queryParts.push($part)
		$previousPart:=$part
	End for each 
	
	Case of 
		: ($nbParentheses>0)
			For ($i; $nbParentheses; 0; -1)
				$parenthesisPart:=New object:C1471
				$parenthesisPart.type:="parenthesis"
				$parenthesisPart.value:=")"
				This:C1470._queryParts.push($parenthesisPart)
			End for 
		: ($nbParentheses<0)
			For ($i; $nbParentheses; 0)
				$parenthesisPart:=New object:C1471
				$parenthesisPart.type:="parenthesis"
				$parenthesisPart.value:="("
				This:C1470._queryParts.unshift($parenthesisPart)
			End for 
	End case 
	
Function _pushANDOperator()
	
	$operatorPart:=New object:C1471
	$operatorPart.type:="operator"
	$operatorPart.value:="AND"
	This:C1470._queryParts.push($operatorPart)
	
	
	//MARK:-Build the query elements
Function _buildQueryString()
	
	var $subQueryStringPart : Text
	var $subQueryStringParts : Collection
	var $valueToSearch : Variant
	var $field : Object
	var $parameterName : Text
	
	This:C1470._queryStringParts:=New collection:C1472
	
	This:C1470._partIndice:=0
	For each ($part; This:C1470._queryParts)
		
		Case of 
			: ($part.type="value")
				$subQueryStringParts:=New collection:C1472()
				This:C1470._partIndice+=1
				Case of 
					: ($part.tag#Null:C1517)
						$searchFields:=This:C1470._entry.searchfields.query("tag = :1 or tags[] = :1"; $part.tag)
					Else 
						$searchFields:=This:C1470._entry.searchfields.query("onlyWithTag = false or onlyWithTag = null")
				End case 
				For each ($field; $searchFields)
					$subQueryStringPart:=""
					Case of 
						: ($field.withComment)
							$parameterName:="_commentTargets"+String:C10($partIndice)+"_1"
							Case of 
								: (Position:C15($part.value; "me;moi")>0)
									$userUUID:=cs:C1710.sfw_userManager.me.info.UUID
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Comment.query("UUID_User = :1"; $userUUID).extract("UUID_target")
								: (Position:C15($part.value; "other;autre")>0)
									$userUUID:=cs:C1710.sfw_userManager.me.info.UUID
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Comment.query("UUID_User # :1 or UUID_User = null"; $userUUID).extract("UUID_target")
								: (Position:C15($part.value; "false;faux")>0)
									$subQueryStringPart+="Not"
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Comment.all().extract("UUID_target")
								Else 
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Comment.all().extract("UUID_target")
							End case 
							$subQueryStringPart+="(UUID in :"+$parameterName+")"
							
						: ($field.inComment)
							$parameterName:="_inTargets"+String:C10($partIndice)+"_1"
							$valueToSearch:=This:C1470._constructSearchValue($part.value; $field; Bool:C1537($part.tag#Null:C1517))
							Case of 
								: (Value type:C1509($valueToSearch)=Is collection:K8:32)
									$operator:=$valueToSearch.shift()
									Case of 
										: ($operator="in")
											This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Comment.query("comment in :1"; $valueToSearch).extract("UUID_target")
										Else 
											TRACE:C157
									End case 
								Else 
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Comment.query("comment = :1"; $valueToSearch).extract("UUID_target")
							End case 
							$subQueryStringPart+="(UUID in :"+$parameterName+")"
							
						: ($field.levelComment)
							$parameterName:="_levelTargets"+String:C10($partIndice)+"_1"
							If (String:C10(Num:C11($part.value))=$part.value)
								$numLevel:=Num:C11($part.value)
								$numLevel:=($numLevel<1) || ($numLevel>4) ? 4 : $numLevel
							Else 
								$valueToSearch:=This:C1470._constructSearchValue($part.value; $field; Bool:C1537($part.tag#Null:C1517))
								$numLevel:=-1
								Repeat 
									$numLevel+=1
								Until ($numLevel=4) || (cs:C1710.sfw_commentManager.me.levels[String:C10($numLevel)].label=$valueToSearch)
								If ($numLevel=4)
									$numLevel:=3
								End if 
							End if 
							This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Comment.query("ID_level >= :1"; $numLevel).extract("UUID_target")
							$subQueryStringPart+="(UUID in :"+$parameterName+")"
							
						: ($field.withDocument)
							$parameterName:="_DocumentTargets"+String:C10($partIndice)+"_1"
							Case of 
								: (Position:C15($part.value; "me;moi")>0)
									$userUUID:=cs:C1710.sfw_userManager.me.info.UUID
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Document.query("UUID_User = :1"; $userUUID).extract("UUID_target")
								: (Position:C15($part.value; "other;autre")>0)
									$userUUID:=cs:C1710.sfw_userManager.me.info.UUID
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Document.query("UUID_User # :1 or UUID_User = null"; $userUUID).extract("UUID_target")
								: (Position:C15($part.value; "false;faux")>0)
									$subQueryStringPart+="Not"
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Document.all().extract("UUID_target")
								Else 
									This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Document.all().extract("UUID_target")
							End case 
							$subQueryStringPart+="(UUID in :"+$parameterName+")"
							
						: ($field.inDocunentName)
							$parameterName:="_inTargets"+String:C10($partIndice)+"_1"
							$valueToSearch:=This:C1470._constructSearchValue($part.value; $field; Bool:C1537($part.tag#Null:C1517))
							This:C1470._querySettings.parameters[$parameterName]:=ds:C1482.sfw_Document.query("name = :1"; $valueToSearch).extract("UUID_target")
							$subQueryStringPart+="(UUID in :"+$parameterName+")"
							
						: ($field.type=Is integer:K8:5) || ($field.type=Is real:K8:4)
							$valueToSearch:=$part.value
							Case of 
								: ($valueToSearch=">=@")
									$operator:=">="
									$valueToSearch:=Substring:C12($valueToSearch; 3)
								: ($valueToSearch="<=@")
									$operator:="<="
									$valueToSearch:=Substring:C12($valueToSearch; 3)
								: ($valueToSearch=">@")
									$operator:=">"
									$valueToSearch:=Substring:C12($valueToSearch; 2)
								: ($valueToSearch="<@")
									$operator:="<"
									$valueToSearch:=Substring:C12($valueToSearch; 2)
								: ($valueToSearch="#@")
									$operator:="#"
									$valueToSearch:=Substring:C12($valueToSearch; 2)
								Else 
									$operator:="="
							End case 
							$valueToSearch:=This:C1470._constructSearchValue($part.value; $field; Bool:C1537($part.tag#Null:C1517))
							$subQueryStringPart+=This:C1470._buidSubQueryStringPart($field; $valueToSearch; $operator)
						Else 
							$valueToSearch:=This:C1470._constructSearchValue($part.value; $field; Bool:C1537($part.tag#Null:C1517))
							Case of 
								: (Value type:C1509($valueToSearch)=Is collection:K8:32)
									$operator:=$valueToSearch.shift()
									Case of 
										: ($operator="in")
											$subQueryStringPart+=This:C1470._buidSubQueryStringPart($field; $valueToSearch; "in")
										: ($operator="between")
											If ($field.placeHolder#Null:C1517)
												$parameterName:=$field.placeHolder+String:C10($partIndice)+"_1"
												$subQueryStringPart+=($subQueryStringPart="") ? "( " : " OR ("
												$subQueryStringPart+=$field.path+" >= :"+$parameterName
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
												$parameterName:=$field.placeHolder+String:C10($partIndice)+"_2"
												$subQueryStringPart+=" and "+$field.path+" <= :"+$parameterName+" )"
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
											Else 
												$parameterName:=$field.attribute+String:C10($partIndice)+"_1"
												$subQueryStringPart+=($subQueryStringPart="") ? "( " : " OR ("
												$subQueryStringPart+=$field.attribute+" >= :"+$parameterName
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
												$parameterName:=$field.attribute+String:C10($partIndice)+"_2"
												$subQueryStringPart+=" and "+$field.attribute+" <= :"+$parameterName+" )"
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
											End if 
										: ($operator="outside")
											If ($field.placeHolder#Null:C1517)
												$parameterName:=$field.placeHolder+String:C10($partIndice)+"_1"
												$subQueryStringPart+=($subQueryStringPart="") ? "( " : " OR ("
												$subQueryStringPart+=$field.path+" < :"+$parameterName
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
												$parameterName:=$field.placeHolder+String:C10($partIndice)+"_2"
												$subQueryStringPart+=" and "+$field.path+" > :"+$parameterName+" )"
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
											Else 
												$parameterName:=$field.attribute+String:C10($partIndice)+"_1"
												$subQueryStringPart+=($subQueryStringPart="") ? "( " : " OR ("
												$subQueryStringPart+=$field.attribute+" < :"+$parameterName
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
												$parameterName:=$field.attribute+String:C10($partIndice)+"_2"
												$subQueryStringPart+=" and "+$field.attribute+" > :"+$parameterName+" )"
												This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch.shift()
											End if 
										Else 
											$subQueryStringPart+=This:C1470._buidSubQueryStringPart($field; $valueToSearch.shift(); $operator)
									End case 
								: (Value type:C1509($valueToSearch)=Is date:K8:7) && ($valueToSearch=!00-00-00!)
									
								Else 
									$subQueryStringPart+=This:C1470._buidSubQueryStringPart($field; $valueToSearch; "=")
							End case 
					End case 
					$subQueryStringParts.push($subQueryStringPart)
				End for each 
				
				If (Bool:C1537($part.not))
					This:C1470._queryStringParts.push("not("+$subQueryStringParts.join(" OR "; ck ignore null or empty:K85:5)+")")
				Else 
					This:C1470._queryStringParts.push("("+$subQueryStringParts.join(" OR "; ck ignore null or empty:K85:5)+")")
				End if 
				
			: ($part.type="operator")
				This:C1470._queryStringParts.push($part.value)
				
			: ($part.type="parenthesis")
				This:C1470._queryStringParts.push(($part.not ? "not" : "")+$part.value)
				
		End case 
		
	End for each 
	This:C1470._queryString:=This:C1470._queryStringParts.join(" ")
	This:C1470._queryString+=(This:C1470._entry.orderByDefault#Null:C1517) ? " order by "+This:C1470._entry.orderByDefault : ""
	
Function _buidSubQueryStringPart($field : Object; $valueToSearch : Variant; $operator : Text)->$subQueryStringPart : Text
	var $parameterName : Text
	
	If ($field.placeHolder#Null:C1517)
		$parameterName:=$field.placeHolder+String:C10(This:C1470._partIndice)
		$subQueryStringPart:=$field.path+" "+$operator+" :"+$parameterName
		This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch
	Else 
		$parameterName:=$field.attribute+String:C10(This:C1470._partIndice)
		$subQueryStringPart:=$field.attribute+" "+$operator+" :"+$parameterName
		This:C1470._querySettings.parameters[$parameterName]:=$valueToSearch
	End if 
	
Function _constructSearchValue($value : Text; $field : Object; $isInTag : Boolean)->$valueToSearch : Variant
	$typeOfValue:=(Num:C11($field.type)=0) ? Is text:K8:3 : $field.type
	Case of 
		: ($typeOfValue=Is text:K8:3)
			Case of 
				: (Position:C15(";"; $value)>0)
					$valueToSearch:=New collection:C1472("in")
					For each ($valueToPush; Split string:C1554($value; ";"))
						$valueToSearch.push(This:C1470._constructSearchValue($valueToPush; $field; $isInTag))
					End for each 
				: ($value="^@^")
					$valueToSearch:=Substring:C12($value; 2; Length:C16($value)-2)
				: ($value="^@")
					$valueToSearch:=Substring:C12($value; 2)+((Position:C15("@"; $value; *)>0) ? "" : "@")
				: ($value="@^")
					$valueToSearch:=((Position:C15("@"; $value; *)>0) ? "" : "@")+Substring:C12($value; 1; Length:C16($value)-1)
				: (Position:C15("@"; $value; *)>0)
					$valueToSearch:=$value
				Else 
					$valueToSearch:="@"+$value+"@"
			End case 
			If (Not:C34($isInTag))
				This:C1470.searchHighlightParts.push($value)
			End if 
			
		: ($typeOfValue=Is date:K8:7)
			$valueToSearch:=This:C1470._constructSearchValueDate($value; $field; $isInTag)
			
		: ($typeOfValue=Is boolean:K8:9)
			$valueToSearch:=Bool:C1537(Position:C15($value; "true;vrai")>0)
		: ($typeOfValue=Is integer:K8:5)
			$valueToSearch:=Round:C94(Num:C11($value); 0)
		: ($typeOfValue=Is real:K8:4)
			$valueToSearch:=Num:C11($value)
		Else 
			$valueToSearch:=This:C1470._constructSearchValue($value; New object:C1471("type"; Is text:K8:3))
	End case 
	
	
Function _constructSearchValueDate($value : Text; $field : Object; $isInTag : Boolean)->$valueToSearch : Variant
	$operator:="="
	Case of 
		: ($value="")
			$value:="today"
		: ($value=">=@")
			$value:=Substring:C12($value; 3)
			$operator:=">="
		: ($value="<=@")
			$value:=Substring:C12($value; 3)
			$operator:="<="
		: ($value=">@")
			$value:=Substring:C12($value; 2)
			$operator:=">"
		: ($value="<@")
			$value:=Substring:C12($value; 2)
			$operator:="<"
		: ($value="#")
			$value:=Substring:C12($value; 2)
			$operator:="#"
	End case 
	Case of 
		: ($value="today")
			If ($operator="=")
				$valueToSearch:=Current date:C33
			Else 
				$valueToSearch:=New collection:C1472($operator; Current date:C33)
			End if 
		: ($value="tomorrow")
			If ($operator="=")
				$valueToSearch:=Current date:C33+1
			Else 
				$valueToSearch:=New collection:C1472($operator; Current date:C33+1)
			End if 
		: ($value="yesterday")
			If ($operator="=")
				$valueToSearch:=Current date:C33-1
			Else 
				$valueToSearch:=New collection:C1472($operator; Current date:C33-1)
			End if 
		: ($value="7lastdays")
			Case of 
				: ($operator="=")
					$valueToSearch:=New collection:C1472("between"; Current date:C33-7; Current date:C33-1)
				: ($operator="#")
					$valueToSearch:=New collection:C1472("outside"; Current date:C33-7; Current date:C33-1)
				: ($operator=">")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-1)
				: ($operator="<")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-7)
				: ($operator=">=")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-1)
				: ($operator="<=")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-7)
				Else 
					$valueToSearch:=New collection:C1472("between"; Current date:C33-7; Current date:C33-1)
			End case 
		: ($value="7nextdays")
			Case of 
				: ($operator="=")
					$valueToSearch:=New collection:C1472("between"; Current date:C33+1; Current date:C33+7)
				: ($operator="#")
					$valueToSearch:=New collection:C1472("outside"; Current date:C33+1; Current date:C33+7)
				: ($operator=">")
					$valueToSearch:=New collection:C1472($operator; Current date:C33+7)
				: ($operator="<")
					$valueToSearch:=New collection:C1472($operator; Current date:C33+1)
				: ($operator=">=")
					$valueToSearch:=New collection:C1472($operator; Current date:C33+1)
				: ($operator="<=")
					$valueToSearch:=New collection:C1472($operator; Current date:C33+7)
				Else 
					$valueToSearch:=New collection:C1472("between"; Current date:C33+1; Current date:C33+7)
			End case 
			
		: ($value="thisWeek") || ($value="lastWeek") || ($value="nextWeek")
			$numberOfDay:=Day number:C114(Current date:C33)-1
			$numberOfDay:=(($numberOfDay=0) ? 7 : $numberOfDay)+(7*Num:C11($value="lastWeek"))-(7*Num:C11($value="nextWeek"))
			Case of 
				: ($operator="=")
					$valueToSearch:=New collection:C1472("between"; Current date:C33-$numberOfDay+1; Current date:C33-$numberOfDay+7)
				: ($operator="#")
					$valueToSearch:=New collection:C1472("outside"; Current date:C33-$numberOfDay+1; Current date:C33-$numberOfDay+7)
				: ($operator=">")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-$numberOfDay+7)
				: ($operator="<")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-$numberOfDay+1)
				: ($operator=">=")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-$numberOfDay+1)
				: ($operator="<=")
					$valueToSearch:=New collection:C1472($operator; Current date:C33-$numberOfDay+7)
				Else 
					$valueToSearch:=New collection:C1472("between"; Current date:C33-$numberOfDay+1; Current date:C33-$numberOfDay+7)
			End case 
		: ($value="thisMonth") || ($value="lastMonth") || ($value="nextMonth")
			$month:=Month of:C24(Current date:C33)-Num:C11($value="lastMonth")+Num:C11($value="nextMonth")
			$year:=Year of:C25(Current date:C33)
			Case of 
				: ($operator="=")
					$valueToSearch:=New collection:C1472("between"; Add to date:C393(!00-00-00!; $year; $month; 1); Add to date:C393(!00-00-00!; $year; $month+1; 1)-1)
				: ($operator="#")
					$valueToSearch:=New collection:C1472("outside"; Add to date:C393(!00-00-00!; $year; $month; 1); Add to date:C393(!00-00-00!; $year; $month+1; 1)-1)
				: ($operator=">")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; $month+1; 1))
				: ($operator="<")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; $month; 1)-1)
				: ($operator=">=")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; $month; 1))
				: ($operator="<=")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; $month+1; 1)-1)
				Else 
					$valueToSearch:=New collection:C1472("between"; Add to date:C393(!00-00-00!; $year; $month; 1); Add to date:C393(!00-00-00!; $year; $month+1; 1)-1)
			End case 
		: ($value="thisYear") || ($value="lastYear") || ($value="nextYear")
			$year:=Year of:C25(Current date:C33)-Num:C11($value="lastYear")+Num:C11($value="nextYear")
			Case of 
				: ($operator="=")
					$valueToSearch:=New collection:C1472("between"; Add to date:C393(!00-00-00!; $year; 1; 1); Add to date:C393(!00-00-00!; $year; 12; 31))
				: ($operator="#")
					$valueToSearch:=New collection:C1472("outside"; Add to date:C393(!00-00-00!; $year; 1; 1); Add to date:C393(!00-00-00!; $year; 12; 31))
				: ($operator=">")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 12; 31))
				: ($operator="<")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 1; 1))
				: ($operator=">=")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 1; 1))
				: ($operator="<=")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 12; 31))
				Else 
					$valueToSearch:=New collection:C1472("between"; Add to date:C393(!00-00-00!; $year; 1; 1); Add to date:C393(!00-00-00!; $year; 12; 31))
			End case 
		: (Length:C16($value)=4) && (String:C10(Num:C11($value))=$value)
			$year:=Num:C11($value)
			Case of 
				: ($operator="=")
					$valueToSearch:=New collection:C1472("between"; Add to date:C393(!00-00-00!; $year; 1; 1); Add to date:C393(!00-00-00!; $year; 12; 31))
				: ($operator="#")
					$valueToSearch:=New collection:C1472("outside"; Add to date:C393(!00-00-00!; $year; 1; 1); Add to date:C393(!00-00-00!; $year; 12; 31))
				: ($operator=">")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 12; 31))
				: ($operator="<")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 1; 1))
				: ($operator=">=")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 1; 1))
				: ($operator="<=")
					$valueToSearch:=New collection:C1472($operator; Add to date:C393(!00-00-00!; $year; 12; 31))
				Else 
					$valueToSearch:=New collection:C1472("between"; Add to date:C393(!00-00-00!; $year; 1; 1); Add to date:C393(!00-00-00!; $year; 12; 31))
			End case 
		Else 
			$valueToSearch:=Date:C102($value)
	End case 
	
	
	//MARK: -Execute the query
Function perform($entry : Object; $rawSearchbox : Text)->$entitySelection : 4D:C1709.EntitySelection
	
	This:C1470.searchHighlightParts:=New collection:C1472
	This:C1470._entry:=$entry
	This:C1470._searchbox:=$rawSearchbox
	This:C1470._cleanSearchbox()
	If (This:C1470._searchbox="")
		$entitySelection:=This:C1470._all()
	Else 
		$entitySelection:=This:C1470._query()
	End if 
	
Function _all()->$entitySelection : 4D:C1709.EntitySelection
	
	$entitySelection:=ds:C1482[This:C1470._entry.dataclass].all()
	
	
Function _query()->$entitySelection : 4D:C1709.EntitySelection
	
	This:C1470._splitSearchboxInParts()
	This:C1470._buildQueryString()
	
	If (This:C1470._queryString="")  //in case of the analyze return a empty string
		$entitySelection:=This:C1470._all()
	Else 
		$entitySelection:=ds:C1482[This:C1470._entry.dataclass].query(This:C1470._queryString; This:C1470._querySettings)
	End if 
	
	
Function popupOnSearchBox()
	
	var $refMenus : Collection  // a collection to store the references of menus to be able to release later
	var $mainLevel; $tagMenu : Text  //references of menus
	var $tags : Collection  // a collection of all the available tags
	var $tag : Text  // a tag
	var $field : Object  // a object to describe the field
	var $choose : Text  // the parameter selected in the popup menu
	var $startSel; $endSel : Integer  // positions for the selection in the searchbox
	$refMenus:=New collection:C1472()
	
	If (Form:C1466.sfw.entry.searchfields=Null:C1517)
		
		
		
		
		
	Else 
		$mainLevel:=Create menu:C408()
		$refMenus.push($mainLevel)
		$tagMenu:=Create menu:C408()
		$refMenus.push($tagMenu)
		$tagsToPup:=New collection:C1472()
		For each ($field; Form:C1466.sfw.entry.searchfields)
			$tagsToStudy:=New collection:C1472
			If ($field.tag#Null:C1517)
				$tagsToStudy.push($field.tag)
			End if 
			If ($field.tags#Null:C1517)
				$tagsToStudy:=$tagsToStudy.combine($field.tags)
			End if 
			For each ($tagToStudy; $tagsToStudy)
				$indices:=$tagsToPup.indices("tag = :1"; $tagToStudy)
				If ($indices.length=0)
					$tagToPup:=New object:C1471
					$tagToPup.tag:=$tagToStudy
					$tagToPup.prefered:=Num:C11(Form:C1466.sfw.entry.searchPreferedTags.indexOf($tagToPup.tag))
					$tagToPup.field:=$field
					$tagsToPup.push($tagToPup)
				Else 
					$tagToPup:=$tagsToPup.first()
				End if 
			End for each 
		End for each 
		
		For each ($tagToPup; $tagsToPup.query("prefered # -1").orderBy("prefered"))
			$label:=$tagToPup.tag
			If ($tagToPup.field.popupDescription#Null:C1517)
				$label+=" ("+String:C10($tagToPup.field.popupDescription)+")"
			End if 
			APPEND MENU ITEM:C411($tagMenu; $label; *)
			SET MENU ITEM PARAMETER:C1004($tagMenu; -1; "--tag:"+$tagToPup.tag)
		End for each 
		APPEND MENU ITEM:C411($tagMenu; "-")
		For each ($tagToPup; $tagsToPup.query("prefered = -1 and field.popupPart =null").orderBy("tag"))
			$label:=$tagToPup.tag
			If ($tagToPup.field.popupDescription#Null:C1517)
				$label+=" ("+String:C10($tagToPup.field.popupDescription)+")"
			End if 
			APPEND MENU ITEM:C411($tagMenu; $label; *)
			SET MENU ITEM PARAMETER:C1004($tagMenu; -1; "--tag:"+$tagToPup.tag)
		End for each 
		APPEND MENU ITEM:C411($tagMenu; "-")
		$popupParts:=$tagsToPup.extract("field.popupPart").distinct()
		For each ($popupPart; $popupParts)
			For each ($tagToPup; $tagsToPup.query("prefered = -1 and field.popupPart = :1"; $popupPart).orderBy("tag"))
				$label:=$tagToPup.tag
				If ($tagToPup.field.popupDescription#Null:C1517)
					$label+=" ("+String:C10($tagToPup.field.popupDescription)+")"
				End if 
				APPEND MENU ITEM:C411($tagMenu; $label; *)
				SET MENU ITEM PARAMETER:C1004($tagMenu; -1; "--tag:"+$tagToPup.tag)
			End for each 
			APPEND MENU ITEM:C411($tagMenu; "-")
		End for each 
		
		
		
		APPEND MENU ITEM:C411($mainLevel; "tags"; $tagMenu)  //XLIFF
		
		$indices:=Form:C1466.sfw.entry.searchfields.indices("type = :1"; Is date:K8:7)
		If ($indices.length>0)
			$dateMenu:=Create menu:C408()
			$refMenus.push($dateMenu)
			$dates:=Split string:C1554("today;tomorrow;yesterday;7lastdays;7nextdays;thisWeek;lastWeek;nextWeek;thisMonth;lastMonth;nextMonth;thisYear;lastYear;nextYear"; ";").orderBy()
			For each ($date; $dates)
				APPEND MENU ITEM:C411($dateMenu; $date; *)
				SET MENU ITEM PARAMETER:C1004($dateMenu; -1; "--date:"+$date)
			End for each 
			APPEND MENU ITEM:C411($mainLevel; "dates"; $dateMenu)  //XLIFF
		End if 
		
		If (This:C1470.lastSearches.length>0)
			$lastSearchesMenu:=Create menu:C408()
			$refMenus.push($lastSearchesMenu)
			For each ($lastSearch; This:C1470.lastSearches.query("entryIdent = :1"; This:C1470._entry.ident))
				APPEND MENU ITEM:C411($lastSearchesMenu; $lastSearch.search; *)
				SET MENU ITEM PARAMETER:C1004($lastSearchesMenu; -1; "--seach:"+$lastSearch.search)
			End for each 
			APPEND MENU ITEM:C411($mainLevel; "-")
			APPEND MENU ITEM:C411($mainLevel; "last searches"; $lastSearchesMenu)  //XLIFF
		End if 
		
		OBJECT GET COORDINATES:C663(*; "Search_Box_left"; $g; $h; $d; $b)
		$choose:=Dynamic pop up menu:C1006($mainLevel; ""; $g; $b)
		For each ($refMenu; $refMenus)
			RELEASE MENU:C978($refMenu)  //don't forget to release all the menu and submenus created
		End for each 
		
		Case of 
			: ($choose="--tag:@")
				$tag:=Substring:C12($choose; 7)+":"
				GET HIGHLIGHT:C209(*; "Search_Input"; $startSel; $endSel)
				Form:C1466.sfw.searchbox:=Substring:C12(Form:C1466.sfw.searchbox; 1; $startSel-1)+$tag+Substring:C12(Form:C1466.sfw.searchbox; $endSel)
				HIGHLIGHT TEXT:C210(*; "Search_Input"; $startSel+Length:C16($tag); $startSel+Length:C16($tag))
				Form:C1466.sfw.lb_items_search()
				
			: ($choose="--date:@")
				$date:=Substring:C12($choose; 8)
				GET HIGHLIGHT:C209(*; "Search_Input"; $startSel; $endSel)
				Form:C1466.sfw.searchbox:=Substring:C12(Form:C1466.sfw.searchbox; 1; $startSel-1)+$date+Substring:C12(Form:C1466.sfw.searchbox; $endSel)
				HIGHLIGHT TEXT:C210(*; "Search_Input"; $startSel+Length:C16($date); $startSel+Length:C16($date))
				Form:C1466.sfw.lb_items_search()
				
			: ($choose="--seach:@")
				Form:C1466.sfw.searchbox:=Substring:C12($choose; 9)
				Form:C1466.sfw.lb_items_search()
				
		End case 
	End if 