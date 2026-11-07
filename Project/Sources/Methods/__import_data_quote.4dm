//%attributes = {"executedOnServer":true}
// __import_data_quote($mode) -> result
// Replaces the quotes with the legacy export, read from the data folder's DataJson:
// quotes.json, quote_lines.json, quote_assumptions.json, termsConditions.json, and
// wpQuotes/<QuoteNumber>.4wp for the preliminary text.
// Run it through _import_quotesRun, which checks the files and asks first:
// - $mode "check": only says which files are missing and how many quotes there are now
// - $mode "run": empties Quote, QuoteLine and Assumption, then imports (anything else = "check")
// Customers are matched on their name (case and extra spaces ignored), then through the contact
// code; contacts on code + company; staff on first name + last name. What had to be created,
// what could not be linked and the quotes whose total differs from the legacy one are listed in
// Project/imports/quote_import.txt. Legacy fields with no place in Quote are kept in
// moreData.legacy. Ends with _fix_sequences, which moves the "quoteCode" counter past the
// legacy codes (Q251...).
#DECLARE($mode : Text)->$result : Object

var $folder : 4D:C1709.Folder
var $name : Text
var $log : Collection
var $norm : 4D:C1709.Function
var $quotes; $quoteLines; $assumptions; $quoteTerms; $items; $words; $parts : Collection
var $quote; $quoteLine; $assumption; $quoteTerm; $term; $comm : Object
var $customerByName; $companyByContactCode; $contactByKey; $staffByPreparer; $statusByName; $revisionByName : Object
var $quoteUUIDByCode; $assumptionByText; $termByKey; $assumptionLinks; $termLinks : Object
var $staffList : Collection
var $eQuote : cs:C1710.QuoteEntity
var $eQuoteLine : cs:C1710.QuoteLineEntity
var $eContact : cs:C1710.ContactEntity
var $eCustomer : cs:C1710.CustomerEntity
var $eStaff : cs:C1710.StaffEntity
var $eAssumption : cs:C1710.AssumptionEntity
var $eTerm : cs:C1710.TermConditionEntity
var $eRevision : cs:C1710.RevisionEntity
var $e : 4D:C1709.Entity
var $info : Object
var $key; $code; $text; $customerUUID; $staffUUID; $first; $last; $line; $contactCode : Text
var $tel; $ext; $email : Text
var $date : Date
var $amount; $legacyTotal : Real
var $nbLinks; $nbAssumptionCodes; $nbLines; $nbTermLinks : Integer
var $created : Object
var $orphans; $totalDiffs; $noStatus : Collection

$folder:=Folder:C1567(fk data folder:K87:12).folder("DataJson")
$result:=New object:C1471("success"; False:C215; "missing"; New collection:C1472; "nbQuotes"; ds:C1482.Quote.all().length)
For each ($name; New collection:C1472("quotes.json"; "quote_lines.json"; "quote_assumptions.json"; "termsConditions.json"))
	If (Not:C34($folder.file($name).exists))
		$result.missing.push($name)
	End if
End for each
If ($mode#"run") || ($result.missing.length>0)
	$result.success:=($result.missing.length=0)
	return
End if

$log:=New collection:C1472("Quote import - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178); "")
$created:=New object:C1471("customers"; New collection:C1472; "contacts"; 0; "staff"; New collection:C1472)
$orphans:=New collection:C1472
$noStatus:=New collection:C1472
// a name as it is compared: lower case, no spaces around, single spaces inside
$norm:=Formula:C1597(Replace string:C233(Replace string:C233(Replace string:C233(Lowercase:C14(cs:C1710.Util.me.trim(String:C10($1); [" "; "\r"; "\t"])); "  "; " "); "  "; " "); "  "; " "))

TRUNCATE TABLE:C1051([QuoteLine:129])
TRUNCATE TABLE:C1051([Quote:128])
TRUNCATE TABLE:C1051([Assumption:2])

// what is already in the data file
$customerByName:=New object:C1471
For each ($e; ds:C1482.Customer.all())
	$key:=$norm.call(Null:C1517; $e.name)
	If ($key#"") && ($customerByName[$key]=Null:C1517)
		$customerByName[$key]:=$e.UUID
	End if
End for each
$companyByContactCode:=New object:C1471
$contactByKey:=New object:C1471
For each ($e; ds:C1482.Contact.query("code # :1"; ""))
	$contactByKey[$e.code+"|"+$e.UUID_Company]:=$e.UUID
	If ($companyByContactCode[$e.code]=Null:C1517)
		$companyByContactCode[$e.code]:=$e.UUID_Company
	End if
End for each
$staffList:=New collection:C1472
For each ($e; ds:C1482.Staff.all())
	$staffList.push(New object:C1471("uuid"; $e.UUID; "first"; Lowercase:C14($e.firstName); "last"; Lowercase:C14($e.lastName)))
End for each
$staffByPreparer:=New object:C1471
$statusByName:=New object:C1471
For each ($e; ds:C1482.QuoteStatus.all())
	$statusByName[Lowercase:C14($e.name)]:=$e.UUID
End for each
$revisionByName:=New object:C1471
For each ($e; ds:C1482.Revision.all())
	$revisionByName[Uppercase:C13($e.name)]:=$e.UUID
End for each

// 1. Quotes
$quoteUUIDByCode:=New object:C1471
$quotes:=JSON Parse:C1218($folder.file("quotes.json").getText())
For each ($quote; $quotes)

	// customer: by name, then through the contact code, else created
	$contactCode:=String:C10($quote.ContactCode)  // a number in some exports
	$customerUUID:=String:C10($customerByName[$norm.call(Null:C1517; $quote.Company)])
	If ($customerUUID="") && ($contactCode#"") && ($companyByContactCode[$contactCode]#Null:C1517)
		If (ds:C1482.Customer.get($companyByContactCode[$contactCode])#Null:C1517)
			$customerUUID:=$companyByContactCode[$contactCode]
		End if
	End if
	If ($customerUUID="")
		$eCustomer:=ds:C1482.Customer.new()
		$eCustomer.name:=cs:C1710.Util.me.trim(String:C10($quote.Company); [" "; "\r"])
		$eCustomer.moreData:=New object:C1471("createdByQuoteImport"; True:C214)
		$info:=$eCustomer.save()
		$customerUUID:=$eCustomer.UUID
		$customerByName[$norm.call(Null:C1517; $quote.Company)]:=$customerUUID
		$created.customers.push($eCustomer.name+" (first seen on "+$quote.QuoteNumber+")")
	End if

	// contact: on code + company, else created
	$eContact:=Null:C1517
	If ($contactCode#"")
		$key:=$contactCode+"|"+$customerUUID
		If ($contactByKey[$key]#Null:C1517)
			$eContact:=ds:C1482.Contact.get($contactByKey[$key])
		End if
	End if
	If ($eContact=Null:C1517)
		$eContact:=ds:C1482.Contact.new()
		$eContact.UUID_Company:=$customerUUID
		$eContact.UUID_Customer:=$customerUUID
		$eContact.firstName:=String:C10($quote.Fname)
		$eContact.lastName:=String:C10($quote.Lname)
		$eContact.code:=$contactCode
		$eContact.contactDetails:=New object:C1471("addresses"; New collection:C1472; "communications"; New collection:C1472)
		$eContact.contactDetails.addresses.push(New object:C1471("type"; "main"; "detail"; New object:C1471(\
			"street_1"; String:C10($quote.add1); "street_2"; String:C10($quote.add2); "city"; String:C10($quote.add3); \
			"state"; String:C10($quote.ST); "postcode"; String:C10($quote.zip); "country"; "US"; "iso_code_2"; "US")))
		If (String:C10($quote.tel_num)#"")
			$eContact.contactDetails.communications.push(New object:C1471("type"; "phone"; "contact"; $quote.tel_num; "comment"; ""))
		End if
		If (String:C10($quote.fax_num)#"")
			$eContact.contactDetails.communications.push(New object:C1471("type"; "fax"; "contact"; $quote.fax_num; "comment"; ""))
		End if
		If (String:C10($quote.email_addr)#"")
			$eContact.contactDetails.communications.push(New object:C1471("type"; "email"; "contact"; $quote.email_addr; "comment"; ""))
		End if
		$info:=$eContact.save()
		If ($eContact.code#"")
			$contactByKey[$eContact.code+"|"+$customerUUID]:=$eContact.UUID
		End if
		$created.contacts+=1
	End if

	// staff: first name + last name, then a single person with that first name, else created
	$staffUUID:=""
	If (String:C10($quote.PreparedBy)#"")
		If ($staffByPreparer[$quote.PreparedBy]=Null:C1517)
			$words:=Split string:C1554($quote.PreparedBy; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
			$first:=Lowercase:C14($words[0])
			$last:=($words.length>1) ? Lowercase:C14($words[$words.length-1]) : ""
			$parts:=$staffList.query("first = :1"; $first)
			For each ($comm; $parts) Until ($staffUUID#"")
				If ($last#"") && (($comm.last=$last) || (Position:C15($last; $comm.last)>0) || (Position:C15($comm.last; $last)>0))
					$staffUUID:=$comm.uuid
				End if
			End for each
			If ($staffUUID="") && ($parts.length=1)
				$staffUUID:=$parts[0].uuid
			End if
			If ($staffUUID="")
				$eStaff:=ds:C1482.Staff.new()
				$eStaff.firstName:=$words[0]
				$eStaff.lastName:=$words.slice(1).join(" ")
				$eStaff.contactDetails:=New object:C1471("communications"; New collection:C1472)
				$info:=$eStaff.save()
				$staffUUID:=$eStaff.UUID
				$staffList.push(New object:C1471("uuid"; $staffUUID; "first"; $first; "last"; Lowercase:C14($eStaff.lastName)))
				$created.staff.push($quote.PreparedBy)
			End if
			$staffByPreparer[$quote.PreparedBy]:=$staffUUID
		End if
		$staffUUID:=$staffByPreparer[$quote.PreparedBy]

		// the preparer's email and phone go on the staff record, once
		If (String:C10($quote.PreparerEmailAndTel)#"")
			$eStaff:=ds:C1482.Staff.get($staffUUID)
			If ($eStaff.contactDetails=Null:C1517)
				$eStaff.contactDetails:=New object:C1471
			End if
			If ($eStaff.contactDetails.communications=Null:C1517)
				$eStaff.contactDetails.communications:=New collection:C1472
			End if
			If ($eStaff.contactDetails.communications.length=0)
				$tel:=""
				$ext:=""
				$email:=""
				For each ($line; Split string:C1554($quote.PreparerEmailAndTel; "\r"; sk ignore empty strings:K86:1+sk trim spaces:K86:2))
					If (Position:C15("@"; $line)>0)
						$email:=$line
					Else
						$tel:=cs:C1710.Util.me.trim(Replace string:C233(Replace string:C233($line; "Tel:"; ""); "Tel :"; ""); [" "])
						Case of
							: (Position:C15("ext"; $tel)>0)
								$parts:=Split string:C1554($tel; "ext"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
							: (Position:C15("x"; $tel)>0)
								$parts:=Split string:C1554($tel; "x"; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
							Else
								$parts:=New collection:C1472($tel)
						End case
						$tel:=($parts.length>0) ? $parts[0] : ""
						$ext:=($parts.length>1) ? Replace string:C233($parts[1]; "."; "") : ""
					End if
				End for each
				If ($tel#"")
					$eStaff.contactDetails.communications.push(New object:C1471("type"; "phone"; "contact"; $tel; "comment"; ""))
				End if
				If ($ext#"")
					$eStaff.contactDetails.communications.push(New object:C1471("type"; "ext"; "contact"; cs:C1710.Util.me.trim($ext; [" "]); "comment"; ""))
				End if
				If ($email#"")
					$eStaff.contactDetails.communications.push(New object:C1471("type"; "email"; "contact"; $email; "comment"; ""))
				End if
				If ($eStaff.contactDetails.communications.length>0)
					$info:=$eStaff.save()
				End if
			End if
		End if
	End if

	// the quote
	$eQuote:=ds:C1482.Quote.new()
	$eQuote.code:=$quote.QuoteNumber
	$eQuote.UUID_Customer:=$customerUUID
	If ($staffUUID#"")
		$eQuote.UUID_Staff:=$staffUUID
	End if
	$eQuote.subject:=cs:C1710.Util.me.trim(String:C10($quote.Subject); [" "; "\r"])
	$eQuote.reference:=cs:C1710.Util.me.trim(String:C10($quote.Reference); [" "; "\r"])
	$eQuote.division:=String:C10($quote.Division)
	$eQuote.voided:=Bool:C1537($quote.void)
	$eQuote.assumptions:=New object:C1471("UUIDs"; New collection:C1472)
	$eQuote.termsConditions:=New object:C1471("UUIDs"; New collection:C1472)

	// Date("2019-07-17") gave !00-00-00! here, which left every imported quote without a date
	$date:=ds:C1482.Quote.legacyDate($quote.Qdate)
	If ($date#!00-00-00!)
		$eQuote.stmpCreation:=cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
	End if

	If (String:C10($quote.Status)#"")
		If ($statusByName[Lowercase:C14($quote.Status)]#Null:C1517)
			$eQuote.UUID_Status:=$statusByName[Lowercase:C14($quote.Status)]
		Else
			$noStatus.push($quote.QuoteNumber+" (\""+$quote.Status+"\")")
		End if
	End if

	If (String:C10($quote.Revision)#"")
		If ($revisionByName[Uppercase:C13($quote.Revision)]=Null:C1517)
			$eRevision:=ds:C1482.Revision.new()
			$eRevision.name:=Uppercase:C13($quote.Revision)
			$eRevision.code:=Uppercase:C13($quote.Revision)
			$eRevision.levelID:=Num:C11(ds:C1482.Revision.all().max("levelID"))+1
			$info:=$eRevision.save()
			$revisionByName[$eRevision.name]:=$eRevision.UUID
		End if
		$eQuote.UUID_Revision:=$revisionByName[Uppercase:C13($quote.Revision)]
	End if

	$eQuote.moreData:=New object:C1471("mainContact"; New object:C1471("UUID"; $eContact.UUID); "secondaryContacts"; New collection:C1472)
	// legacy fields with no place in Quote, kept for later (revision history, follow-up, PO link...)
	$eQuote.moreData.legacy:=New object:C1471(\
		"comments"; String:C10($quote.Comments); \
		"quoteHistory"; String:C10($quote.QuoteHistory); \
		"recvdPONumber"; String:C10($quote.RecvdPONumber); \
		"poDate"; Substring:C12(String:C10($quote.POdate); 1; 10); \
		"totalInPO"; Num:C11($quote.TotalInPO); \
		"totalThisQuote"; Num:C11($quote.TotalThisQuote); \
		"subjectKey"; String:C10($quote.Subjectkey); \
		"copy"; String:C10($quote.Copy); \
		"copyToEmailAddr"; String:C10($quote.CopyToEmailAddr); \
		"salutation"; String:C10($quote.salutation); \
		"followUpActionBy"; String:C10($quote.FollowUpActionBy); \
		"status"; String:C10($quote.Status))

	If ($folder.file("wpQuotes/"+$quote.QuoteNumber+".4wp").exists)
		$eQuote.optionalPreliminaryTxt_wr:=WP Import document:C1318($folder.file("wpQuotes/"+$quote.QuoteNumber+".4wp").platformPath)
	End if

	$info:=$eQuote.save()
	If ($info.success)
		$quoteUUIDByCode[$eQuote.code]:=$eQuote.UUID
	Else
		$orphans.push($quote.QuoteNumber+": quote not saved ("+String:C10($info.statusText)+")")
	End if
End for each

// 2. Assumptions: one master record per text, linked to every quote that used it, in legacy order
$assumptions:=JSON Parse:C1218($folder.file("quote_assumptions.json").getText())
For each ($assumption; $assumptions)
	$assumption.qn:=Num:C11($assumption.QuoteNum)
	$assumption.n:=Num:C11($assumption.AssmptNum)
End for each
$assumptions:=$assumptions.orderBy("qn asc, n asc")
$assumptionByText:=New object:C1471
$assumptionLinks:=New object:C1471
For each ($assumption; $assumptions)
	$text:=String:C10($assumption.Line)
	If ($text#"")
		If ($assumptionByText[$text]=Null:C1517)
			$nbAssumptionCodes+=1
			$eAssumption:=ds:C1482.Assumption.new()
			$eAssumption.value:=$text
			$eAssumption.code:=String:C10($nbAssumptionCodes)
			$info:=$eAssumption.save()
			$assumptionByText[$text]:=$eAssumption.UUID
		End if
		If ($quoteUUIDByCode[$assumption.QuoteNum]=Null:C1517)
			$orphans.push("assumption "+String:C10($assumption.AssmptNum)+" of "+$assumption.QuoteNum+": no such quote")
		Else
			If ($assumptionLinks[$assumption.QuoteNum]=Null:C1517)
				$assumptionLinks[$assumption.QuoteNum]:=New collection:C1472
			End if
			If ($assumptionLinks[$assumption.QuoteNum].indexOf($assumptionByText[$text])<0)
				$assumptionLinks[$assumption.QuoteNum].push($assumptionByText[$text])
			End if
		End if
	End if
End for each

// 3. Terms and conditions: one record per code + value, linked in the legacy order
$termByKey:=New object:C1471
For each ($e; ds:C1482.TermCondition.all())
	$termByKey[$e.code+"|"+$e.value]:=$e.UUID
End for each
$termLinks:=New object:C1471
$quoteTerms:=JSON Parse:C1218($folder.file("termsConditions.json").getText())
For each ($quoteTerm; $quoteTerms)
	If ($quoteUUIDByCode[$quoteTerm.quoteNumber]=Null:C1517)
		$orphans.push("terms of "+String:C10($quoteTerm.quoteNumber)+": no such quote")
	Else
		$termLinks[$quoteTerm.quoteNumber]:=New collection:C1472
		$items:=($quoteTerm.items=Null:C1517) ? New collection:C1472 : $quoteTerm.items.orderBy("order asc")
		For each ($term; $items)
			$key:=String:C10($term.code)+"|"+String:C10($term.value)
			If ($termByKey[$key]=Null:C1517)
				$eTerm:=ds:C1482.TermCondition.new()
				$eTerm.code:=String:C10($term.code)
				$eTerm.value:=String:C10($term.value)
				$info:=$eTerm.save()
				$termByKey[$key]:=$eTerm.UUID
			End if
			If ($termLinks[$quoteTerm.quoteNumber].indexOf($termByKey[$key])<0)
				$termLinks[$quoteTerm.quoteNumber].push($termByKey[$key])
			End if
		End for each
	End if
End for each

// one save per quote for both lists
For each ($code; $quoteUUIDByCode)
	If ($assumptionLinks[$code]#Null:C1517) || ($termLinks[$code]#Null:C1517)
		$eQuote:=ds:C1482.Quote.get($quoteUUIDByCode[$code])
		If ($assumptionLinks[$code]#Null:C1517)
			$eQuote.assumptions:=New object:C1471("UUIDs"; $assumptionLinks[$code])
			$nbLinks+=$assumptionLinks[$code].length
		End if
		If ($termLinks[$code]#Null:C1517)
			$eQuote.termsConditions:=New object:C1471("UUIDs"; $termLinks[$code])
			$nbTermLinks+=$termLinks[$code].length
		End if
		$info:=$eQuote.save()
		If (Not:C34($info.success))
			$orphans.push($code+": assumptions / terms not saved ("+String:C10($info.statusText)+")")
		End if
	End if
End for each

// 4. Lines: a legacy amount above quantity x unit price becomes the minimum lot charge, one below it is kept
$quoteLines:=JSON Parse:C1218($folder.file("quote_lines.json").getText())
For each ($quoteLine; $quoteLines)
	If ($quoteUUIDByCode[$quoteLine.QuoteNum]=Null:C1517)
		$orphans.push("line "+String:C10($quoteLine.item)+" of "+String:C10($quoteLine.QuoteNum)+": no such quote")
	Else
		$eQuoteLine:=ds:C1482.QuoteLine.new()
		$eQuoteLine.UUID_Quote:=$quoteUUIDByCode[$quoteLine.QuoteNum]
		$eQuoteLine.num:=Num:C11($quoteLine.item)
		$eQuoteLine.quantity:=Num:C11($quoteLine.qty)
		$eQuoteLine.unitPrice:=Num:C11($quoteLine.unit_price)
		$eQuoteLine.description:=String:C10($quoteLine.Description)
		$amount:=Num:C11($quoteLine.Amount)
		$eQuoteLine.moreData:=New object:C1471
		Case of
			: ($amount>(($eQuoteLine.quantity*$eQuoteLine.unitPrice)+0.005))
				$eQuoteLine.minLotCharge:=$amount  // above quantity x unit price: a minimum lot charge
			: (Abs:C99($amount-($eQuoteLine.quantity*$eQuoteLine.unitPrice))>0.005)
				$eQuoteLine.moreData.amount:=$amount  // below it (a discount): kept as it was typed
		End case
		$info:=$eQuoteLine.save()
		If ($info.success)
			$nbLines+=1
		Else
			$orphans.push("line "+String:C10($quoteLine.item)+" of "+$quoteLine.QuoteNum+": not saved ("+String:C10($info.statusText)+")")
		End if
	End if
End for each

// 5. Check: the quote's total in GA against the legacy TotalThisQuote
$totalDiffs:=New collection:C1472
For each ($quote; $quotes)
	If ($quoteUUIDByCode[$quote.QuoteNumber]#Null:C1517)
		$eQuote:=ds:C1482.Quote.get($quoteUUIDByCode[$quote.QuoteNumber])
		$amount:=$eQuote.amountNumber
		$legacyTotal:=Num:C11($quote.TotalThisQuote)
		If (Abs:C99($amount-$legacyTotal)>0.01)
			$totalDiffs.push($quote.QuoteNumber+": GA "+String:C10($amount; "###,###,##0.00")+" / legacy "+String:C10($legacyTotal; "###,###,##0.00"))
		End if
	End if
End for each

// 6. The quote codes are the legacy ones: move the "quoteCode" counter past them
$result.sequences:=_fix_sequences

// report
$result.success:=True:C214
$result.nbQuotes:=OB Keys:C1719($quoteUUIDByCode).length
$result.summary:=String:C10($result.nbQuotes)+" quotes, "+String:C10($nbLines)+" lines, "\
+String:C10($nbLinks)+" assumption links ("+String:C10($nbAssumptionCodes)+" assumptions), "\
+String:C10($nbTermLinks)+" term links.\r"\
+"Created: "+String:C10($created.customers.length)+" customers, "+String:C10($created.contacts)+" contacts, "+String:C10($created.staff.length)+" staff.\r"\
+String:C10($noStatus.length)+" unknown statuses, "+String:C10($orphans.length)+" items not linked, "+String:C10($totalDiffs.length)+" totals different from legacy."

$log.push($result.summary)
$log.push("")
$log.push("Customers created ("+String:C10($created.customers.length)+"):")
If ($created.customers.length>0)
	$log.push("  "+$created.customers.join("\r\n  "))
End if 
$log.push("")
$log.push("Staff created ("+String:C10($created.staff.length)+"):")
If ($created.staff.length>0)
	$log.push("  "+$created.staff.join("\r\n  "))
End if 
$log.push("")
$log.push("Quotes with a status that does not exist ("+String:C10($noStatus.length)+"):")
If ($noStatus.length>0)
	$log.push("  "+$noStatus.join("\r\n  "))
End if 
$log.push("")
$log.push("Not linked or not saved ("+String:C10($orphans.length)+"):")
If ($orphans.length>0)
	$log.push("  "+$orphans.join("\r\n  "))
End if 
$log.push("")
$log.push("Total different from the legacy TotalThisQuote ("+String:C10($totalDiffs.length)+"):")
If ($totalDiffs.length>0)
	$log.push("  "+$totalDiffs.join("\r\n  "))
End if 
$log.push("")
$log.push("Counters (_fix_sequences):")
For each ($comm; $result.sequences.counters)
	$log.push("  "+$comm.counter+": before "+String:C10($comm.before)+", highest "+String:C10($comm.highest)+", after "+String:C10($comm.after))
End for each

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("quote_import.txt").setText($log.join("\r\n"))
