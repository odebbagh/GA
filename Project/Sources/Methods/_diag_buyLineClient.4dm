//%attributes = {}
// _diag_buyLineClient
// READ-ONLY. Run it from a 4D REMOTE client. Nothing is saved.
// _diag_buyLineJson found every buy line valid on the server, yet a Remote client fails on
// ds.BuyingOrderLine.all() with "JSON mal-formé ... ',' found". So the fault is in what the
// server SENDS. This loads the lines the way a client does, in Try():
//   1. in blocks of 200 (query + toCollection of every attribute, computed ones included)
//   2. a failing block line by line
//   3. a failing line attribute by attribute
// then asks the server to dump those lines, with each computed attribute evaluated there.
// Report: Project/imports/buyLineClient_diag.txt (written by the server).

var $uuids; $block; $badUUIDs; $attrs; $out; $errors; $badAttrs : Collection
var $uuid; $attr; $msg; $path : Text
var $i; $blockSize; $badBlocks : Integer
var $value : Variant
var $dump : Object

//---every attribute a client can ask for: stored and computed, no relations
$attrs:=[]
For each ($attr; ds:C1482.BuyingOrderLine)
	If (ds:C1482.BuyingOrderLine[$attr].kind="storage") || (ds:C1482.BuyingOrderLine[$attr].kind="calculated")
		$attrs.push($attr)
	End if
End for each

$out:=["_diag_buyLineClient "+String:C10(Current date:C33; ISO date:K1:8)+" "+String:C10(Current time:C178); ""]

//---0. the call that failed in _import_glAccounts
$value:=Try(ds:C1482.BuyingOrderLine.all().first())
$out.push("ds.BuyingOrderLine.all().first(): "+_diag_buyLineClientErr(Last errors:C1799))

$uuids:=_diag_buyLineJsonSrv("uuids").uuids
$out.push("lines on the server: "+String:C10($uuids.length))

//---1. blocks
$blockSize:=200
$badUUIDs:=[]
$badBlocks:=0
For ($i; 0; $uuids.length-1; $blockSize)
	$block:=$uuids.slice($i; $i+$blockSize)
	$value:=Try(ds:C1482.BuyingOrderLine.query("UUID in :1"; $block).toCollection($attrs))
	$msg:=_diag_buyLineClientErr(Last errors:C1799)
	If ($msg#"OK")
		$badBlocks:=$badBlocks+1
		//---2. line by line
		For each ($uuid; $block)
			$value:=Try(ds:C1482.BuyingOrderLine.query("UUID = :1"; $uuid).toCollection($attrs))
			If (_diag_buyLineClientErr(Last errors:C1799)#"OK")
				$badUUIDs.push($uuid)
			End if
		End for each
	End if
End for
$out.push("blocks of "+String:C10($blockSize)+" failing: "+String:C10($badBlocks)+"   lines failing: "+String:C10($badUUIDs.length))
$out.push("")

//---3. attribute by attribute, for the first 30 failing lines
For each ($uuid; $badUUIDs.slice(0; 30))
	$badAttrs:=[]
	For each ($attr; $attrs)
		$value:=Try(ds:C1482.BuyingOrderLine.query("UUID = :1"; $uuid).toCollection([$attr]))
		$msg:=_diag_buyLineClientErr(Last errors:C1799)
		If ($msg#"OK")
			$badAttrs.push($attr+" ("+$msg+")")
		End if
	End for each
	$out.push("LINE "+$uuid+"  failing attributes: "+(($badAttrs.length=0) ? "none alone" : $badAttrs.join(", ")))
End for each

//---and what the server holds for them
If ($badUUIDs.length>0)
	$out.push("")
	$out.push("SERVER DUMP of the first 10 failing lines:")
	For each ($dump; _diag_buyLineJsonSrv("dump"; $badUUIDs.slice(0; 10)).lines)
		$out.push(JSON Stringify:C1217($dump; *))
	End for each
End if

$path:=_diag_buyLineJsonSrv("write"; {name: "buyLineClient_diag.txt"; text: $out.join("\r\n")}).path

cs:C1710.sfw_dialog.me.alert("Buy lines failing on this client: "+String:C10($badUUIDs.length)+\
	" (in "+String:C10($badBlocks)+" block(s) of "+String:C10($blockSize)+")"+\
	"\r\rReport (on the server): "+$path)
