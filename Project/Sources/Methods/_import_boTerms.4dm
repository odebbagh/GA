//%attributes = {}

// Fills [BOTerm] with the standard Buy Order quality terms and conditions
// (QTC01..QTC17 - reference CS-11003 / GAF#1411 Rev. 05).
//
// One record per term:
//   code    : the QTC reference
//   content : a 4D Write Pro document holding the clause - the QTC code is bold,
//             the rest of the text is normal weight. QTC08 keeps its numbered
//             sub-items as separate paragraphs.
//
// Re-runnable: a term whose code already exists is rewritten in place, the others
// are created. Nothing else in [BOTerm] is touched.

var $terms : Collection
var $term : Object
var $line : Text
var $boTermDataClass : 4D:C1709.DataClass
var $eTerm : 4D:C1709.Entity
var $wp : Object
var $range : Object
var $result : Object
var $created : Integer
var $updated : Integer
var $failed : Integer
var $models : Collection
var $model : Object
var $code : Text
var $items : Collection
var $order : Integer
var $isFirst : Boolean
var $eModel : 4D:C1709.Entity
var $missingCodes : Collection
var $modelsCreated : Integer
var $modelsUpdated : Integer
var $modelsFailed : Integer

$boTermDataClass:=ds:C1482["BOTerm"]

If ($boTermDataClass=Null:C1517)
	ALERT:C41("DataClass BOTerm not found. Create the table first.")
Else

	$terms:=New collection:C1472

	$terms.push(New object:C1471(\
		"code"; "QTC01"; \
		"text"; "Order needs to be shipped EXCLUSIVELY to GOLDEN ALTOS CORPORATION."))

	$terms.push(New object:C1471(\
		"code"; "QTC02"; \
		"text"; "TRANSSHIPMENT: Order to be EXCLUSIVELY shipped to the 3rd PARTY appearing on Golden Altos Corp.'s Purchase Order. One copy of your shipper, process flow descriptions (as applicable) and C of Cs shall be sent to Golden Altos Corp. by U.S. mail within 24 hours of such shipment."))

	$terms.push(New object:C1471(\
		"code"; "QTC03"; \
		"text"; "SOURCE INSPECTION: DO NOT SHIP this order until inspected or tested by Golden Altos Corp. at your premises."))

	$terms.push(New object:C1471(\
		"code"; "QTC04"; \
		"text"; "PRIME CONTRACTOR SOURCE INSPECTION: DO NOT SHIP this order until inspected or tested by Golden Altos Corp.'s customer at your premises. Notify Golden Altos Corp. as soon as the order is ready for prime contractor source inspection."))

	$terms.push(New object:C1471(\
		"code"; "QTC05"; \
		"text"; "SOURCE SURVEILLANCE: Acceptance of this order authorizes Golden Altos Corp. or their customer to inspect and/or monitor the Supplier's quality or manufacturing system for the purpose of verifying order quality and integrity. Golden Altos Corp. shall notify you of such a visit at least 72 hours prior to verification."))

	$terms.push(New object:C1471(\
		"code"; "QTC06"; \
		"text"; "FIRST ARTICLE INSPECTION AT SUPPLIER'S FACILITY: This order is subject to Sample First Article Acceptance at YOUR facility prior to delivery and/or acceptance of the balance of the order. Delivery or production of articles, other than the sample, prior to First Article Acceptance by us shall be at YOUR OWN RISK. The sample article(s) submitted shall be representative in all aspects of the articles to be delivered on the remainder of this order. The numbers of sample article(s) shall appear on Supplier's Purchase Order and constitute objective evidence of conformance to requirements. Source inspection for the purpose of Sample First Article acceptance shall be made by Golden Altos Corp. at least 48 hours in advance of such inspection."))

	$terms.push(New object:C1471(\
		"code"; "QTC07"; \
		"text"; "FIRST ARTICLE INSPECTION AT GOLDEN ALTOS CORP.'S FACILITY: This order is subject to Sample First Article Acceptance at Golden Altos Corp. prior to delivery and/or acceptance of the balance of the order. Delivery or production of articles, other than the sample, prior to First Article Acceptance by us shall be at YOUR OWN RISK. The sample article(s) submitted shall be representative in all aspects of the articles to be delivered on the remainder of this order. The numbers of sample article(s) shall appear on Supplier's Purchase Order and constitute objective evidence of conformance to requirements. Source inspection for the purpose of Sample First Article acceptance shall be made by Golden Altos Corp. at least 48 hours in advance of such inspection"))

	$terms.push(New object:C1471(\
		"code"; "QTC08"; \
		"text"; "REQUIRED CERTIFICATIONS: Ship a reproducible copy of all CERTIFICATE OF COMPLIANCE with this order or any portion thereof to the recipients called out in the attached Purchase Order. The certificate shall contain a statement that attests to your full compliance with requirements stipulated in the attached Purchase Order and that you hold for review any documented evidence of such compliance. The certificate shall be signed by the supplier's quality representative. Any shipments received without required certifications shall be held at Receiving and NO PAYMENTS will be made until such certifications are received from the supplier. As a minimum, the supplier's Certificate of Compliance shall contain the following information."; \
		"lines"; New collection:C1472(\
		"1. Golden Altos Corp.'s Purchase Order Number."; \
		"2. Golden Altos Corp.'s Part No and print revision letter, as applicable."; \
		"3. Supplier's shipping document number."; \
		"4. Quantity of shipped articles."; \
		"5. When applicable, serial numbers and/or lot numbers of article(s).A"; \
		"6. The certification of compliance statement.")))

	$terms.push(New object:C1471(\
		"code"; "QTC09"; \
		"text"; "FUNCTIONAL TEST REPORTS: Ship a REPRODUCIBLE COPY of all inspection or test parameters associated with this order or any portion thereof. Each report shall include the signature of the supplier's quality representative or the quality representative of the agency responsible for such inspection or test."))

	$terms.push(New object:C1471(\
		"code"; "QTC10"; \
		"text"; "QUALITY MANAGEMENT SYSTEM REQUIREMENTS: You shall have developed and maintain a quality management system conforming to ISO 9001, or equivalent, unless different or expanded requirements are identified in Golden Altos Corp.'s Purchase Order."))

	$terms.push(New object:C1471(\
		"code"; "QTC11"; \
		"text"; "IDENTIFICATION OF MATERIAL'S SHELF LIFE: Supplier shall label or otherwise clearly identify each article with a shelf life appearing in this order with the cure date, expiration date, and special storage and handling requirements in addition to normal identification information such as description, part or code number, specification number, type size and/or quantity. The identification, including special handing conditions shall be recorded on certification and shipping documents. Upon its delivery to Golden Altos Corp., the supplier's shipped aged-dated material shall have a minimum 80% of its shelf life remaining for use."))

	$terms.push(New object:C1471(\
		"code"; "QTC12"; \
		"text"; "ELECTRO-STATIC DISCHARGE REQUIREMENT: Article(s) referenced in this Purchase Order shall be packaged in containers capable of protecting the material from damage caused by electro-static discharge (ESD) in accordance with the latest version of either MIL-S-19491 or MIL-M-55565. All package(s) shipped to us SHALL BE MARKED EXTERNALLY with the following, or equivalent statement: CAUTION: Contains material susceptible to damage when subjected to electro-static discharge (ESD)."))

	$terms.push(New object:C1471(\
		"code"; "QTC13"; \
		"text"; "PACKING, PACKAGING AND PRESERVATION: Supplier shall utilize appropriate packing, packaging and preservation methods and materials to ensure article(s) associated with the Purchase Order are received by Golden Altos Corp. in acceptable condition."))

	$terms.push(New object:C1471(\
		"code"; "QTC14"; \
		"text"; "MRB AUTHORITY EXCLUSION: Supplier HAS NOT BEEN GRANTED MRB authority to disposition non-conforming articles(s) named in attached Purchase Order. Supplier agrees to contact Golden Altos Corp. to disposition any such deviation before proceeding with the order."))

	$terms.push(New object:C1471(\
		"code"; "QTC15"; \
		"text"; "GOVERNMENT OR BUYER SUPPLIED TOOLING OR TEST EQUIPMENT: All property consigned to supplier by Golden Altos Corp. including such property owned by Golden Altos Corp.'s customer or the U.S. Government appearing on or associated with the attached Purchase Order, shall be controlled and accounted for by the supplier in accordance with FAR 45. In accepting Purchase Order, supplier agrees upon demand to permit Golden Altos Corp. to examine the property at any time."))

	$terms.push(New object:C1471(\
		"code"; "QTC16"; \
		"text"; "Golden Altos or end customer has the ability to access and visit the facility for verification or audit purposes."))

	$terms.push(New object:C1471(\
		"code"; "QTC17"; \
		"text"; "Record Retention: The records under this purchasing order. The records pertaining to production processes, incoming and in-process inspections shall be retained for a minimum of 5 years after shipment to Golden Altos"))

	$created:=0
	$updated:=0
	$failed:=0

	For each ($term; $terms)

		//build the Write Pro document: the QTC code in bold, the clause in normal weight
		$wp:=WP New:C1317()

		$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
		WP SET TEXT:C1574($range; $term.code; wk append:K81:179)
		WP SET ATTRIBUTES:C1342($range; wk font bold:K81:68; True:C214)

		$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
		WP SET TEXT:C1574($range; Char:C90(Tab:K15:37)+$term.text; wk append:K81:179)
		WP SET ATTRIBUTES:C1342($range; wk font bold:K81:68; False:C215)

		//numbered sub-items (QTC08) go on their own paragraphs, still normal weight
		If ($term.lines#Null:C1517)
			For each ($line; $term.lines)
				$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
				WP SET TEXT:C1574($range; Char:C90(Carriage return:K15:38)+Char:C90(Tab:K15:37)+$line; wk append:K81:179)
				WP SET ATTRIBUTES:C1342($range; wk font bold:K81:68; False:C215)
			End for each
		End if

		$eTerm:=$boTermDataClass.query("code = :1"; $term.code).first()
		If ($eTerm=Null:C1517)
			$eTerm:=$boTermDataClass.new()
			$eTerm.code:=$term.code
			$eTerm.content:=$wp
			$result:=$eTerm.save()
			If ($result.success)
				$created:=$created+1
			Else
				$failed:=$failed+1
			End if
		Else
			$eTerm.content:=$wp
			$result:=$eTerm.save()
			If ($result.success)
				$updated:=$updated+1
			Else
				$failed:=$failed+1
			End if
		End if

	End for each

	//Mark:-Predefined models
	//The standard term sets offered on the buy order Terms page. Each model stores
	//the chosen terms with their order in boTerms, plus the assembled Write Pro
	//document in model. Same upsert rule as above, keyed on the model name.

	$models:=New collection:C1472

	$models.push(New object:C1471(\
		"name"; "OUTSIDE SERVICE"; \
		"codes"; New collection:C1472("QTC01"; "QTC08"; "QTC10"; "QTC12"; "QTC13"; "QTC14"; "QTC16"; "QTC17")))

	$models.push(New object:C1471(\
		"name"; "PACKAGES & LIDS"; \
		"codes"; New collection:C1472("QTC01"; "QTC08"; "QTC09"; "QTC10"; "QTC12"; "QTC13"; "QTC16"; "QTC17")))

	$models.push(New object:C1471(\
		"name"; "CALIBRATION /EQUIPMENT SERVICE"; \
		"codes"; New collection:C1472("QTC01"; "QTC08"; "QTC10"; "QTC13"; "QTC16"; "QTC17")))

	$models.push(New object:C1471(\
		"name"; "TOOLS/FIXTURES/ MISCELLANEOUS"; \
		"codes"; New collection:C1472("QTC01"; "QTC10"; "QTC13"; "QTC16"; "QTC17")))

	$models.push(New object:C1471(\
		"name"; "TRANSENE/CHEMICALS (NOT CRITICAL)"; \
		"codes"; New collection:C1472("QTC01"; "QTC08"; "QTC10"; "QTC11"; "QTC13"; "QTC16"; "QTC17")))

	$models.push(New object:C1471(\
		"name"; "EPOXY, FILM, INK, 3M, WIRES (Critical)"; \
		"codes"; New collection:C1472("QTC01"; "QTC08"; "QTC09"; "QTC10"; "QTC11"; "QTC13"; "QTC16"; "QTC17")))

	//source list reads "QTC012" for this one - taken as QTC12, there is no QTC012
	$models.push(New object:C1471(\
		"name"; "(COMPONENTS) CAPS, PACKAGES, LIDS, RESISTORS (Critical)"; \
		"codes"; New collection:C1472("QTC01"; "QTC08"; "QTC09"; "QTC10"; "QTC11"; "QTC12"; "QTC13"; "QTC16"; "QTC17")))

	$modelsCreated:=0
	$modelsUpdated:=0
	$modelsFailed:=0
	$missingCodes:=New collection:C1472

	If (ds:C1482["BOTermsModel"]=Null:C1517)
		ALERT:C41("DataClass BOTermsModel not found - the terms were imported but no model was built.")
	Else

		For each ($model; $models)

			$items:=New collection:C1472
			$wp:=WP New:C1317()
			$isFirst:=True:C214
			$order:=0

			For each ($code; $model.codes)
				$eTerm:=ds:C1482.BOTerm.query("code = :1"; $code).first()
				If ($eTerm=Null:C1517)
					$missingCodes.push($model.name+"/"+$code)
				Else
					$order:=$order+1
					$items.push(New object:C1471("UUID"; $eTerm.UUID; "order"; $order))
					If (Not:C34($isFirst))
						//blank paragraph between two terms
						$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
						WP SET TEXT:C1574($range; Char:C90(Carriage return:K15:38); wk append:K81:179)
					End if
					WP INSERT DOCUMENT:C1411($wp; $eTerm.content; wk append:K81:179)
					$isFirst:=False:C215
				End if
			End for each

			$eModel:=ds:C1482.BOTermsModel.query("name = :1"; $model.name).first()
			If ($eModel=Null:C1517)
				$eModel:=ds:C1482.BOTermsModel.new()
				$eModel.name:=$model.name
				$eModel.boTerms:=New object:C1471("items"; $items)
				$eModel.model:=$wp
				$result:=$eModel.save()
				If ($result.success)
					$modelsCreated:=$modelsCreated+1
				Else
					$modelsFailed:=$modelsFailed+1
				End if
			Else
				$eModel.boTerms:=New object:C1471("items"; $items)
				$eModel.model:=$wp
				$result:=$eModel.save()
				If ($result.success)
					$modelsUpdated:=$modelsUpdated+1
				Else
					$modelsFailed:=$modelsFailed+1
				End if
			End if

		End for each
	End if

	ALERT:C41("Import termine - BO terms created: "+String:C10($created)+" | updated: "+String:C10($updated)+" | failed: "+String:C10($failed)\
		+" || models created: "+String:C10($modelsCreated)+" | updated: "+String:C10($modelsUpdated)+" | failed: "+String:C10($modelsFailed)\
		+($missingCodes.length>0 ? " | codes not found: "+$missingCodes.join(", ") : ""))

End if
