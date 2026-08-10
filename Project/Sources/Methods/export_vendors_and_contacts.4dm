//%attributes = {}

//Instruction :

//-Do not execute on framework version
//-copy the method and paste in the old version of the application
//-execute to export vendors & contacts from [BUY_ORDERS] to the DataJson folder

//Vendors are grouped by a normalized name (case, spaces, dots, commas,
//dashes, underscores and apostrophes ignored) so that "ACME Inc." and
//"Acme-Inc" count as one vendor. Contacts are deduplicated per vendor.

C_TEXT($folderPath; $normalizedName; $contactKey)
C_TEXT($policyKey; $templateName)
C_BLOB($wpBlob)
C_OBJECT($myFolder; $vendors; $seenContacts; $contact)
C_OBJECT($exportedPolicyDocs; $policyFolder)
C_COLLECTION($records)

$folderPath:=Get 4D folder(Database folder)+"DataJson"

$myFolder:=Folder(Convert path system to POSIX($folderPath))

If (Not($myFolder.exists))
	$myFolder.create()
End if

$vendors:=New object  // normalized vendor name -> vendor object
$seenContacts:=New object  // normalized vendor name -> map of contact keys already added

ALL RECORDS([BUY_ORDERS])

While (Not(End selection([BUY_ORDERS])))

	// normalize the vendor name so near-identical spellings group together
	$normalizedName:=Lowercase([BUY_ORDERS]VENDOR)
	$normalizedName:=Replace string($normalizedName; " "; "")
	$normalizedName:=Replace string($normalizedName; "."; "")
	$normalizedName:=Replace string($normalizedName; ","; "")
	$normalizedName:=Replace string($normalizedName; "-"; "")
	$normalizedName:=Replace string($normalizedName; "_"; "")
	$normalizedName:=Replace string($normalizedName; "'"; "")

	If ($normalizedName#"")

		If ($vendors[$normalizedName]=Null)
			$vendors[$normalizedName]:=New object(\
				"vendor_name"; [BUY_ORDERS]VENDOR; \
				"vendor_address"; New object(\
				"address_1"; [BUY_ORDERS]Vendor_add1; \
				"address_2"; [BUY_ORDERS]Vendor_add2; \
				"city"; [BUY_ORDERS]Vendor_add3; \
				"state"; [BUY_ORDERS]Vendor_ST; \
				"zip_code"; [BUY_ORDERS]Vendor_ZIP; \
				"country"; [BUY_ORDERS]Vendor_Country\
				); \
				"shipping_address"; [BUY_ORDERS]ShippingAddr; \
				"remit_to_address"; New object(\
				"address_1"; [BUY_ORDERS]Vendor_Radd1; \
				"address_2"; [BUY_ORDERS]Vendor_Radd2; \
				"city"; [BUY_ORDERS]Vendor_Radd3; \
				"state"; [BUY_ORDERS]Vendor_RST; \
				"zip_code"; [BUY_ORDERS]Vendor_RZIP; \
				"country"; [BUY_ORDERS]Vendor_RCountry\
				); \
				"contacts"; New collection\
				)

			$seenContacts[$normalizedName]:=New object
		End if

		If ([BUY_ORDERS]Attention_To#"")

			// key on name+email+phone, ignoring case, spaces and dots
			$contactKey:=Lowercase([BUY_ORDERS]Attention_To+"|"+[BUY_ORDERS]Attention_Email+"|"+[BUY_ORDERS]Attention_Tel)
			$contactKey:=Replace string($contactKey; " "; "")
			$contactKey:=Replace string($contactKey; "."; "")

			If ($seenContacts[$normalizedName][$contactKey]=Null)

				$contact:=New object(\
					"name"; [BUY_ORDERS]Attention_To; \
					"email"; [BUY_ORDERS]Attention_Email; \
					"fax"; [BUY_ORDERS]Attention_Fax; \
					"phone"; [BUY_ORDERS]Attention_Tel\
					)

				$vendors[$normalizedName].contacts.push($contact)
				$seenContacts[$normalizedName][$contactKey]:=True
			End if
		End if
	End if

	NEXT RECORD([BUY_ORDERS])
End while

// flatten the vendor map into a collection
$records:=New collection

For each ($normalizedName; $vendors)
	$records.push($vendors[$normalizedName])
End for each

vhDoc:=Create document($myFolder.platformPath+"vendors_and_contacts_export.json")

If (OK=1)
	SEND PACKET(vhDoc; JSON Stringify($records))
	CLOSE DOCUMENT(vhDoc)
End if

// ------------------------------------------------------------------
// Buy orders & their line items -> buyOrders_export.json
// JSON keys are shaped for the new [BuyingOrder]/[BuyingOrderLine]
// tables; whatever has no direct field lands in moreData at import.
// ------------------------------------------------------------------

// The 3 terms templates -> DataJson/<name>.4wp
For each ($templateName; New collection("BuyOrderTerms"; "BuyOrderTerms_CriticalMaterials"; "BuyOrderTerms_CriticalService"))
	QUERY([Formats]; [Formats]Name=$templateName)
	If (Records in selection([Formats])>0)
		WP EXPORT DOCUMENT([Formats]ContentsWP_; $myFolder.platformPath+$templateName+".4wp"; wk 4wp)
	End if
End for each

// Buy_policy_ WP documents are deduplicated by content: every record was
// stamped from one of the 3 templates, so most are byte-identical. Each
// distinct document is written once to DataJson/buyPolicyDocs/<sha1>.4wp
// and the record only carries the key.
$exportedPolicyDocs:=New object
$policyFolder:=$myFolder.folder("buyPolicyDocs")

If (Not($policyFolder.exists))
	$policyFolder.create()
End if

$records:=New collection

ALL RECORDS([BUY_ORDERS])

While (Not(End selection([BUY_ORDERS])))

	$record:=New object

	$record.boNumber:=[BUY_ORDERS]SEQ_NUM
	$record.orderDate:=[BUY_ORDERS]ISSUE_DATE
	$record.vendor_name:=[BUY_ORDERS]VENDOR
	$record.addTerms:=[BUY_ORDERS]Add_terms
	$record.salesTax:=[BUY_ORDERS]T_salestax
	$record.lineItemsTotal:=[BUY_ORDERS]T_Amt
	$record.totalPaid:=[BUY_ORDERS]T_Paid
	$record.totalDue:=[BUY_ORDERS]T_Due
	$record.requestor:=[BUY_ORDERS]Requestor
	$record.approver1:=[BUY_ORDERS]Approver1
	$record.approver2:=[BUY_ORDERS]Approver2
	$record.discountDays:=[BUY_ORDERS]DDAYS
	$record.netDays:=[BUY_ORDERS]NetDays
	$record.onHold:=[BUY_ORDERS]OnHold
	$record.nonApproved:=[BUY_ORDERS]Non_approved
	$record.glac:=[BUY_ORDERS]GLAC
	$record.asset:=[BUY_ORDERS]Asset
	$record.salesTaxRate:=[BUY_ORDERS]ST_rate
	$record.closed:=[BUY_ORDERS]Closed
	$record.dateClosed:=[BUY_ORDERS]Date_closed
	$record.currency:=[BUY_ORDERS]Currency
	$record.signature1:=[BUY_ORDERS]Signature1
	$record.signature2:=[BUY_ORDERS]Signature2
	$record.internalNotes:=[BUY_ORDERS]INTERNAL_NOTES
	$record.requisition:=[BUY_ORDERS]Requistion
	$record.autoInc:=[BUY_ORDERS]Auto_inc
	$record.division:=[BUY_ORDERS]Division
	$record.buyPolicyKey:=""

	If (Not(OB Is empty([BUY_ORDERS]Buy_policy_)))
		SET BLOB SIZE($wpBlob; 0)
		WP EXPORT VARIABLE([BUY_ORDERS]Buy_policy_; $wpBlob; wk 4wp)

		If (BLOB size($wpBlob)>0)
			$policyKey:=Generate digest($wpBlob; SHA1 digest)

			If ($exportedPolicyDocs[$policyKey]=Null)
				WP EXPORT DOCUMENT([BUY_ORDERS]Buy_policy_; $policyFolder.platformPath+$policyKey+".4wp"; wk 4wp)
				$exportedPolicyDocs[$policyKey]:=True
			End if

			$record.buyPolicyKey:=$policyKey
		End if
	End if
	$record.buyOrderLimit:=[BUY_ORDERS]BO_limit
	$record.fob:=[BUY_ORDERS]FOB
	$record.shipVia:=[BUY_ORDERS]ShipVia
	$record.buyersCode:=[BUY_ORDERS]BuyersCode
	$record.buyer:=[BUY_ORDERS]Buyer
	$record.dateTimeStamp:=[BUY_ORDERS]DateTimeStamp
	$record.creationDateTimeStamp:=[BUY_ORDERS]CreationDateTimeStamp
	$record.uniqueID:=[BUY_ORDERS]UniqueID

	$record.attention:=New object(\
		"name"; [BUY_ORDERS]Attention_To; \
		"email"; [BUY_ORDERS]Attention_Email; \
		"fax"; [BUY_ORDERS]Attention_Fax; \
		"phone"; [BUY_ORDERS]Attention_Tel\
		)

	$record.vendor_address:=New object(\
		"address_1"; [BUY_ORDERS]Vendor_add1; \
		"address_2"; [BUY_ORDERS]Vendor_add2; \
		"city"; [BUY_ORDERS]Vendor_add3; \
		"state"; [BUY_ORDERS]Vendor_ST; \
		"zip_code"; [BUY_ORDERS]Vendor_ZIP; \
		"country"; [BUY_ORDERS]Vendor_Country\
		)

	$record.remit_to_address:=New object(\
		"address_1"; [BUY_ORDERS]Vendor_Radd1; \
		"address_2"; [BUY_ORDERS]Vendor_Radd2; \
		"city"; [BUY_ORDERS]Vendor_Radd3; \
		"state"; [BUY_ORDERS]Vendor_RST; \
		"zip_code"; [BUY_ORDERS]Vendor_RZIP; \
		"country"; [BUY_ORDERS]Vendor_RCountry\
		)

	$record.shipping_address:=[BUY_ORDERS]ShippingAddr

	$record.lines:=New collection

	QUERY([BUY_ITEMS]; [BUY_ITEMS]PO_NUM=[BUY_ORDERS]SEQ_NUM)

	While (Not(End selection([BUY_ITEMS])))

		$line:=New object

		$line.boNumber:=[BUY_ITEMS]PO_NUM
		$line.qty:=[BUY_ITEMS]QTY
		$line.unitPrice:=[BUY_ITEMS]Unit_Price
		$line.requiredDate:=[BUY_ITEMS]Date_required
		$line.dateIn:=[BUY_ITEMS]Date_in
		$line.receivedBy:=[BUY_ITEMS]Recd_by
		$line.taxable:=[BUY_ITEMS]Taxable
		$line.freight:=[BUY_ITEMS]Freight
		$line.lineTotal:=[BUY_ITEMS]Line_total
		$line.item:=[BUY_ITEMS]Item
		$line.description:=[BUY_ITEMS]Description
		$line.tax:=[BUY_ITEMS]TAX
		$line.orderDate:=[BUY_ITEMS]Order_Date
		$line.okToPay:=[BUY_ITEMS]OK_to_Pay
		$line.paidDate:=[BUY_ITEMS]Paid_date
		$line.checkNumber:=[BUY_ITEMS]Check_num
		$line.payAmount:=[BUY_ITEMS]Pay_amt
		$line.amountOutstanding:=[BUY_ITEMS]Amt_outstanding
		$line.vendor:=[BUY_ITEMS]Vendor
		$line.invoiceNumber:=[BUY_ITEMS]Invoice_num
		$line.invoiceDate:=[BUY_ITEMS]Invoice_date
		$line.qtyIn:=[BUY_ITEMS]Qtyin
		$line.payBefore:=[BUY_ITEMS]Pay_Before
		$line.returnToVendor:=[BUY_ITEMS]Return_To_Vendor
		$line.assetListNumber:=[BUY_ITEMS]Assetlist_num
		$line.exception:=[BUY_ITEMS]Exception
		$line.jobNumber:=[BUY_ITEMS]Int_jobnum
		$line.multiChecks:=[BUY_ITEMS]Multi_chks
		$line.totalPaid:=[BUY_ITEMS]T_paid
		$line.lastPayDate:=[BUY_ITEMS]Last_pay_date
		$line.supPsNumber:=[BUY_ITEMS]Sup_ps_num
		$line.inventory:=[BUY_ITEMS]Inventory
		$line.consumable:=[BUY_ITEMS]Consumable
		$line.partNumber:=[BUY_ITEMS]Part_num
		$line.discountDays:=[BUY_ITEMS]Ddays
		$line.relationalString:=[BUY_ITEMS]RelationalString
		$line.division:=[BUY_ITEMS]Division
		$line.glAccount:=[BUY_ITEMS]Glac
		$line.asset:=[BUY_ITEMS]Asset
		$line.disputedInvoice:=[BUY_ITEMS]Disputed_inv
		$line.vendorPartNumber:=[BUY_ITEMS]Vendor_partnum
		$line.invalid:=[BUY_ITEMS]Invalid
		$line.currency:=[BUY_ITEMS]Currency
		$line.virtualInventory:=[BUY_ITEMS]Virtual_inventory
		$line.seqNumber:=[BUY_ITEMS]Seq_Number
		$line.checkFlag:=[BUY_ITEMS]CheckFlag
		$line.dateTimeStamp:=[BUY_ITEMS]DateTimeStamp
		$line.creationDateTimeStamp:=[BUY_ITEMS]CreationDateTimeStamp
		$line.units:=[BUY_ITEMS]Units
		$line.uniqueID:=[BUY_ITEMS]UniqueID
		$line.unitPriceWithSalesTax:=[BUY_ITEMS]UnitPriceWithSalesTax
		$line.documentsInDocServer:=[BUY_ITEMS]DocumentsinDocServer
		$line.confirmationDate:=[BUY_ITEMS]ConfirmationDate
		$line.comments:=[BUY_ITEMS]Comments
		$line.billRecognitionDate:=[BUY_ITEMS]BillRecognitionDate

		$record.lines.push($line)

		NEXT RECORD([BUY_ITEMS])
	End while

	$records.push($record)

	NEXT RECORD([BUY_ORDERS])
End while

vhDoc:=Create document($myFolder.platformPath+"buyOrders_export.json")

If (OK=1)
	SEND PACKET(vhDoc; JSON Stringify($records))
	CLOSE DOCUMENT(vhDoc)
End if
